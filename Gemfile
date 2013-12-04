source 'https://rubygems.org'

gemspec

gem 'diff-lcs',     '~> 1.1.2'
gem 'rake'
gem 'true',         '0.2.0.rc.4'

# these are only required for docs/development, not for running test cases
unless ENV["CI"]
  gem 'sassdoc'
  gem 'rdoc'
  gem 'colorize'
  gem 'perftools.rb'
end
