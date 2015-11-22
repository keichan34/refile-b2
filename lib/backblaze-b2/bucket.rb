module BackblazeB2
  class Bucket
    def initialize(client, bucket_name)
      @client = client
      @bucket_name = bucket_name
    end

    def download_file(file_name)
      @client.request(:get, file_url(file_name))
    end

    def file_url(file_name)
      [@client.download_url, "file", @bucket_name, file_name].join("/")
    end
  end
end
