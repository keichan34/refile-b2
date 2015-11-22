require "refile"
require "refile/b2/version"
require "backblaze-b2"

module Refile
  module B2
    class Backend
      extend Refile::BackendMacros
      attr_reader :directory

      attr_reader :max_size

      def initialize(account_id:, application_key:, bucket:, prefix: nil, max_size: nil, hasher: Refile::RandomHasher.new)
        @hasher = hasher
        @prefix = prefix
        @max_size = max_size
        @client = BackblazeB2::Client.new(account_id, application_key)
        @bucket_name = bucket
        @bucket = @client.bucket(@bucket_name)
      end

      verify_uploadable def upload(uploadable)
        id = @hasher.hash(uploadable)

        @bucket.upload_file file_path(id), uploadable

        Refile::File.new(self, id)
      end

      verify_id def get(id)
        Refile::File.new(self, id)
      end

      verify_id def delete(id)
        @bucket.delete_file(file_path(id))
      end

      verify_id def open(id)
        StringIO.new(@bucket.download_file(file_path(id)))
      end

      verify_id def read(id)
        @bucket.download_file(file_path(id))
      end

      verify_id def size(id)
        read(id).bytesize if exists?(id)
      end

      verify_id def exists?(id)
        @bucket.download_file(file_path(id)) != nil
      end

      def clear!(confirm = nil)
        raise Refile::Confirm unless confirm == :confirm
        @bucket.clear_bucket
      end

      private

      verify_id def file_path(id)
        [*@prefix, id].join("/")
      end
    end
  end
end
