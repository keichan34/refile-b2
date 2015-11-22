require "backblaze-b2/spec_helper"

RSpec.describe BackblazeB2::Bucket, :vcr do
  let(:client) { BackblazeB2::Client.new("TEST_CLIENT_ID", "TEST_CLIENT_SECRET") }
  let(:bucket) { client.bucket("test-bucket") }

  it "initializes a bucket object" do
    expect(bucket).to_not be_nil
  end

  context "downloading a file" do
    it "succeeds when the file exists" do
      expect(bucket.download_file("hello.html").strip).to eq("<html>hello</html>")
    end

    it "returns nil if the file does not exist" do
      expect(bucket.download_file "not-exist.html").to eq(nil)
    end
  end

  context "uploading a file" do
    it "succeeds" do
      expect(
        bucket.upload_file("newfile.html", StringIO.new("<html>new hello</html>")).status
      ).to eq(200)
    end
  end

  context "deleting a file" do
    it "succeeds" do
      filename = "file_to_delete.txt"
      other_file = "file_to_save.txt"
      bucket.upload_file(filename, StringIO.new("to delete"))
      bucket.upload_file(other_file, StringIO.new("to save"))

      bucket.delete_file(filename)

      expect(bucket.download_file(filename)).to eq nil
      expect(bucket.download_file(other_file)).to eq "to save"
    end
  end

  context "clearing the bucket" do
    it "succeeds" do
      filenames = 3.times.map { |i| "file_to_delete_#{i}.txt" }
      filenames.each do |filename|
        bucket.upload_file(filename, StringIO.new("to delete"))
      end
      bucket.clear_bucket
      filenames.each do |filename|
        expect(bucket.download_file(filename)).to eq nil
      end
    end
  end
end
