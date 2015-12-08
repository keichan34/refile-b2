require 'backblaze-b2/backends/httpclient'
require 'backblaze-b2/bucket'

module BackblazeB2
  class Client
    def initialize(account_id, application_key, backend: BackblazeB2::Backends::HTTPClient)
      @account_id = account_id
      @backend = backend.new

      @backend.b2_authorize_account(
        account_id: account_id,
        application_key: application_key)
    end

    attr_reader :backend

    def bucket(bucket_name)
      Bucket.new(self, bucket_name)
    end

    def buckets
      resp = backend.b2_list_buckets "accountId" => @account_id
      resp.success? && resp.body["buckets"] || []
    end
  end
end
