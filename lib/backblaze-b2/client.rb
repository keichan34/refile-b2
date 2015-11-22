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

      authorize_account!(application_key)
    end

    attr_accessor :api_url
    attr_accessor :download_url

    def bucket(bucket_name)
      Bucket.new(self, bucket_name)
    end

    def request(method, uri, query = nil, body = nil, header = {})
      c = HTTPClient.new
      header["Authorization"] = @authorization_token
      c.request(method, uri, query, body, header)
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
