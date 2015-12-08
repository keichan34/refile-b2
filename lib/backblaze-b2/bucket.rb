require 'digest'

module BackblazeB2
  class Bucket
    def initialize(client, bucket_name)
      @client = client
      @bucket_name = bucket_name
      @bucket_obj = nil

      get_bucket_id!
    end

    def download_file(file_name)
      r = @client.backend.request(:get, file_url(file_name))
      if r.status == 200
        r.body
      else
        nil
      end
    end

    def upload_file(file_name, file)
      upload = @client.backend.b2_get_upload_url(bucketId: @bucket_obj["bucketId"])

      if upload.failure?
        fail "Upload fail: #{upload.body.inspect}"
      end

      sha1 = Digest::SHA1.new
      file.rewind
      while buf = file.read(512)
        sha1 << buf
      end
      file.rewind

      @client.backend.request(:post, upload.body["uploadUrl"],
        body: file,
        header: {
          "Authorization" => upload.body["authorizationToken"],
          "X-Bz-File-Name" => file_name,
          "Content-Type" => "b2/x-auto",
          "X-Bz-Content-Sha1" => sha1.hexdigest
        })
    end

    # Deletes all versions of this file.
    def delete_file(file_name)
      delete_file_or_files file_name
    end

    # Deletes all version of all files in the bucket.
    def clear_bucket
      delete_file_or_files nil
    end

    def file_url(file_name)
      [@client.backend.download_url, "file", @bucket_name, file_name].join("/")
    end

    private

    def get_bucket_id!
      @bucket_obj = @client.buckets.find do |bucket_obj|
        bucket_obj["bucketName"] == @bucket_name
      end || fail("Bucket #{@bucket_name} does not exist.")
    end

    def delete_file_or_files(file_name_or_nil = nil, next_file_name: nil)
      params = {
        "bucketId" => @bucket_obj["bucketId"]
      }
      if file_name_or_nil
        params["startFileName"] = file_name_or_nil
      end

      resp = @client.backend.b2_list_file_versions(params)

      if resp.failure?
        fail("Failure. #{resp.body.inspect}")
      end

      resp.body["files"].select do |file|
        file["action"] == "upload"
      end.select do |file|
        if file_name_or_nil
          file["fileName"] == file_name_or_nil
        else
          true
        end
      end.each do |file|
        resp = @client.backend.b2_delete_file_version(
          "fileName" => file["fileName"],
          "fileId" => file["fileId"])

        if resp.failure?
          fail "Error deleting version: #{resp.body}"
        end
      end

      if (file_name_or_nil != nil && file_name_or_nil == resp.body["nextFileName"]) || (file_name_or_nil == nil && resp.body["nextFileName"])
        delete_file_or_files(file_name_or_nil, next_file_name: resp.body["nextFileName"])
      end
    end
  end
end
