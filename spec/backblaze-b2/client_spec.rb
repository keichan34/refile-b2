require "backblaze-b2/spec_helper"

RSpec.describe BackblazeB2::Client, :vcr do
  let(:client) { BackblazeB2::Client.new("TEST_CLIENT_ID", "TEST_CLIENT_SECRET") }

  it "initializes a client" do
    expect(client).to_not be_nil
  end

  context "buckets" do
    it "lists buckets" do
      expect(client.buckets).to include({
        "accountId" => "TEST_CLIENT_ID",
        "bucketId" => "test-bucket-id",
        "bucketName" => "test-bucket",
        "bucketType" => "allPrivate"
      })
    end

    it "returns a bucket object when the bucket exists" do
      expect(client.bucket("test-bucket")).to_not be_nil
    end

    it "raises an error when a bucket does not exist" do
      expect {
        client.bucket("no-bucket")
      }.to raise_error(RuntimeError)
    end
  end
end

