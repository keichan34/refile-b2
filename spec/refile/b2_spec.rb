require "refile/b2"
require "refile/spec_helper"

RSpec.describe Refile::B2::Backend do
  let(:backend) { Refile::B2::Backend.new(max_size: 100) }

  it_behaves_like :backend
end

