require "refile/b2"
require "refile/spec_helper"

RSpec.describe Refile::B2::Backend, :vcr do
  let(:backend) { Refile::B2::Backend.new(
    bucket: "refile-test-bucket",
    account_id: "TEST_CLIENT_ID",
    application_key: "TEST_CLIENT_SECRET",
    max_size: 100) }

  # it_behaves_like :backend
end

