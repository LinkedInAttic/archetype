$:.push File.expand_path("../lib", __FILE__)

require 'rake'
require 'archetype/version'

unless ENV['CI']
  require 'colorize'
end

@devnull = File.new('/dev/null').path
@docs = './docs'

Dir.glob('tasks/*.rake').each { |r| import r }

# until we have something to actually do as a default,
# lets print out a list of available tasks (`rake -T` for the lazy)
task :default do
  puts %x[rake -T | grep -v RDoc]
end
