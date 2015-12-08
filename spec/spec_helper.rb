require 'vcr'
require 'pry'

require 'backblaze-b2'
require 'backblaze-b2/backends/dummy'

require 'coveralls'
Coveralls.wear!

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
end
