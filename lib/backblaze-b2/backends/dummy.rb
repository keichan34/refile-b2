require 'active_support/core_ext/hash/keys'

module BackblazeB2::Backends
  class Dummy
    class DummyResponse
      def initialize(body, status: 200)
        @body = body
        @status = status
      end

      def failure?
        @status != 200
      end

      def success?
        @status == 200
      end

      def body
        @body
      end

      def status
        @status
      end
    end

    def initialize
      @files = {
        "public-bucket-1" => [
          {
            path: "dummy.txt",
            contents: "hello"
          }
        ],
        "private-bucket-1" => [
          {
            path: "dummy.txt",
            contents: "hello"
          }
        ]
      }
    end

    def buckets
      return [] if @account_id.nil?

      @buckets ||= [
        {
          "accountId" => @account_id,
          "bucketId" => "public-bucket-1",
          "bucketName" => "public-bucket-1",
          "bucketType" => "allPublic"
        },
        {
          "accountId" => @account_id,
          "bucketId" => "private-bucket-1",
          "bucketName" => "private-bucket-1",
          "bucketType" => "allPrivate"
        }
      ]
    end

    API_URL = "https://api900.backblaze.example"
    AUTHORIZATION_TOKEN = "fake_auth_token"
    DOWNLOAD_URL = "https://f900.backblaze.example"

    def b2_authorize_account(account_id:, application_key:)
      @account_id = account_id
      @application_key = application_key

      DummyResponse.new({
        "accountId" => account_id,
        "apiUrl" => API_URL,
        "authorizationToken" => AUTHORIZATION_TOKEN,
        "downloadUrl" => DOWNLOAD_URL
      })
    end

    def download_url
      DOWNLOAD_URL
    end

    def api_url
      API_URL
    end

    def b2_list_buckets(args = {})
      args.symbolize_keys!
      if args[:accountId] == @account_id
        DummyResponse.new({
          "buckets" => buckets
        })
      else
        DummyResponse.new({
          "code" => "403",
          "message" => "Forbidden",
          "status" => 403
        }, status: 403)
      end
    end

    def b2_get_upload_url(args = {})
      args.symbolize_keys!
      DummyResponse.new({
        "bucketId" => args[:bucketId],
        "uploadUrl" => "https://pod.backblaze.example/upload_file_endpoint/" + args[:bucketId],
        "authorizationToken" => AUTHORIZATION_TOKEN
      })
    end

    def b2_list_file_versions(args = {})
      args.symbolize_keys!
      DummyResponse.new({
        "files" => @files[args[:bucketId]].map do |file|
          {
            "action" => "upload",
            "fileId" => file[:path],
            "fileName" => file[:path],
            "size" => file[:contents].bytesize
          }
        end
      })
    end

    def b2_delete_file_version(args = {})
      args.symbolize_keys!

      @files.each do |_bucket_name, files_in_bucket|
        files_in_bucket.reject! {|file| file[:path] == args[:fileId] }
      end

      DummyResponse.new({
        "fileId" => args[:fileId],
        "fileName" => args[:fileName]
      })
    end

    def request(method, uri, query: nil, body: nil, header: {})
      parsed_uri = URI.parse(uri)
      if method == :post && uri =~ %r{https://pod.backblaze.example/upload_file_endpoint/(?<bucket>.*)}
        @files[$~[:bucket]] << {
          path: header["X-Bz-File-Name"],
          contents: body.read
        }
      elsif parsed_uri.host == URI.parse(DOWNLOAD_URL).host
        # Download file
        _, _file, bucket_name, *filepath = parsed_uri.path.split("/")
        filename = filepath.join("/")
        if @files[bucket_name] && file = @files[bucket_name].find { |b| b[:path] == filename }
          DummyResponse.new(file[:contents])
        else
          DummyResponse.new({"code" => 404, "message" => "file_not_found", "status" => 404}, status: 404)
        end
      end
    end
  end
end
