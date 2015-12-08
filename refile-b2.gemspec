# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'refile/b2/version'

Gem::Specification.new do |spec|
  spec.name          = "refile-b2"
  spec.version       = Refile::B2::VERSION
  spec.authors       = ["Keita Kobayashi"]
  spec.email         = ["keita@kbys.me"]
  spec.summary       = %q{Backblaze B2 backend for Refile}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "refile"
  spec.add_dependency "httpclient", "~> 2.0"
  spec.add_dependency "activesupport", ">= 4.0"

  spec.add_development_dependency "webmock", "~> 1.20.4"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "vcr", "~> 3.0"
  spec.add_development_dependency "fuubar"
end
