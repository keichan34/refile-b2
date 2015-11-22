require 'httpclient'
require 'json'

require 'backblaze-b2/bucket'

module BackblazeB2
  class Client
    def initialize(account_id, application_key)
      @account_id = account_id
      @api_url = nil
      @authorization_token = nil
      @download_url = nil
      @buckets = nil

      authorize_account!(application_key)
    end

    attr_accessor :api_url
    attr_accessor :download_url

    def bucket(bucket_name)
      Bucket.new(self, bucket_name)
    end

    def buckets
      return @buckets if @buckets

      r = request(:post, URI.join(api_url, "/b2api/v1/b2_list_buckets"),
        body: JSON.dump({"accountId" => @account_id}))

      @buckets = if r.status == 200
        JSON.parse(r.body)["buckets"]
      else
        []
      end
    end

    def request(method, uri, query: nil, body: nil, header: {})
      fail "Requires an authorization token." if @authorization_token.nil?
      c = HTTPClient.new
      header["Authorization"] ||= @authorization_token
      c.request(method, uri, query: query, body: body, header: header)
    end

    private

    # https://api.backblaze.com/b2api/v1/b2_authorize_account
    def authorize_account!(application_key)
      c = HTTPClient.new
      c.set_auth(nil, @account_id, application_key)
      c.force_basic_auth = true
      r = c.get("https://api.backblaze.com/b2api/v1/b2_authorize_account")
      if r.status == 200
        body = JSON.parse(r.body)
        @api_url = body["apiUrl"]
        @authorization_token = body["authorizationToken"]
        @download_url = body["downloadUrl"]
        true
      else
        fail "Authorization error: #{r.body}"
      end
    end
  end
end
