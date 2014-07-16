source 'https://rubygems.org'

gemspec

# leverage compass-import-once for improved performance
gem 'compass-import-once'

gem 'rake',         (RUBY_VERSION < '1.9' ? '~> 10.1.1' : '>= 0')
gem 'true',         '~> 0.2.1'
gem 'minitest',     '~> 4.7.5'
gem 'turn',         '~> 0.9.6'
gem 'diffy',        '~> 3.0.3'
gem 'colorize'

# these are only required for docs/development, not for running test cases
unless ENV["CI"]
  gem 'sassdoc'
  gem 'rdoc'
  gem 'perftools.rb'
end

# required for Rubinius to work
# http://docs.travis-ci.com/user/languages/ruby/#Rubinius
platforms :rbx do
  gem 'racc'
  gem 'rubysl', '~> 2.0'
  gem 'psych'
end
