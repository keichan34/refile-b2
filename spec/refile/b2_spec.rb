require "refile/b2"
require "refile/spec_helper"

RSpec.describe Refile::B2::Backend do
  let(:backend) { Refile::B2::Backend.new(
    bucket: "public-bucket-1",
    account_id: "TEST_ACCOUNT_ID",
    application_key: "TEST_APP_KEY",
    max_size: 100,
    client_backend: BackblazeB2::Backends::Dummy) }

  it_behaves_like :backend
end
