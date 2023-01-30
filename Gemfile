source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in responsive_console.gemspec.
gemspec
gem 'shared_helpers', path: '../shared_helpers'

group :development do
  gem 'sqlite3'
end

group :development, :test do
  gem 'minitest'
end

# To use a debugger
# gem 'byebug', group: [:development, :test]
