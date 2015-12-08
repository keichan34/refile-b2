require 'httpclient'
require 'json'
require 'uri'

module BackblazeB2::Backends
  class HTTPClient
    class HTTPResponse
      def initialize(resp)
        @resp = resp
      end

      def failure?
        !success?
      end

      def success?
        @resp.status == 200
      end

      def body
        JSON.parse(@resp.body)
      end
    end

    API_SPEC = {
      :b2_list_buckets => {
        url: "/b2api/v1/b2_list_buckets",
        method: :post,
        required_params: %w(accountId)
      },
      :b2_get_upload_url => {
        url: "/b2api/v1/b2_get_upload_url",
        method: :post,
        required_params: %w(bucketId)
      },
      :b2_list_file_versions => {
        url: "/b2api/v1/b2_list_file_versions",
        method: :post,
        required_params: %w(bucketId)
      },
      :b2_delete_file_version => {
        url: "/b2api/v1/b2_delete_file_version",
        method: :post,
        required_params: %w(fileName fileId)
      }
    }

    attr_reader :api_url
    attr_reader :download_url

    def b2_authorize_account(account_id:, application_key:)
      c = ::HTTPClient.new
      c.set_auth(nil, account_id, application_key)
      c.force_basic_auth = true
      r = c.get("https://api.backblaze.com/b2api/v1/b2_authorize_account")
      if r.status == 200
        body = JSON.parse(r.body)
        @api_url = body["apiUrl"]
        @authorization_token = body["authorizationToken"]
        @download_url = body["downloadUrl"]
        true
      else
        false
      end
    end

    API_SPEC.each do |name, spec|
      define_method(name) do |opts = {}|
        r = request(spec[:method], URI.join(@api_url, spec[:url]), body: JSON.dump(opts))
        HTTPResponse.new(r)
      end
    end

    def request(method, uri, query: nil, body: nil, header: {})
      fail "Requires an authorization token." if @authorization_token.nil?
      c = ::HTTPClient.new
      header["Authorization"] ||= @authorization_token
      c.request(method, uri, query: query, body: body, header: header)
    end
  end
end
