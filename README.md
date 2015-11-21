# Refile::B2 [![Build Status](https://travis-ci.org/keichan34/refile-b2.svg)](https://travis-ci.org/keichan34/refile-b2)

A [Backblaze B2](https://www.backblaze.com/b2/) backend for
[Refile](https://github.com/elabs/refile).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'refile-b2'
```

Set up Refile to use the B2 backend:

``` ruby
Refile.configure do |config|
  config.cache = Refile::B2::Backend.new
  config.store = Refile::B2::Backend.new
end
```

## License

[MIT](License.txt)
