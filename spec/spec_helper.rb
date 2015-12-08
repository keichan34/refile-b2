require 'vcr'
require 'pry'

require 'coveralls'
Coveralls.wear!

require 'backblaze-b2'
require 'backblaze-b2/backends/dummy'

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
end
