source 'https://rubygems.org'

gemspec


# leverage compass-import-once for improved performance
gem 'compass-import-once', :require => "compass/import-once/activate"

gem 'diff-lcs',     '~> 1.2.5'
gem 'rake'
gem 'true',         '0.2.0.rc.4'
gem 'minitest',     '~> 4.7.5'
gem 'turn',         '~> 0.9.6'

# these are only required for docs/development, not for running test cases
unless ENV["CI"]
  gem 'sassdoc'
  gem 'rdoc'
  gem 'colorize'
  gem 'perftools.rb'
  gem 'diffy'
end
