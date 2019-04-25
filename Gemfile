# It's easy to add more libraries or choose different versions. Any libraries
# specified here will be installed and made available to your morph.io scraper.
# Find out more: https://morph.io/documentation/ruby

source 'https://rubygems.org'

ruby '2.6.3'

gem 'scraperwiki', git: 'https://github.com/openaustralia/scraperwiki-ruby.git', branch: 'morph_defaults'
gem 'pry'
gem 'typhoeus'
gem 'nokogiri'

group :development do
  gem 'dotenv'
end

group :test do
  gem 'rspec'
  gem 'vcr'
  gem 'webmock'
end
