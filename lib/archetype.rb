require 'compass'

#
# Initialize Archetype and register it as a Compass extension
#
module Archetype
  # extension info
  @archetype = {}
  @archetype[:name] = 'archetype'
  @archetype[:path] = File.expand_path(File.join(File.dirname(__FILE__), ".."))
  # register the extension
  def self.register
    Compass::Frameworks.register(@archetype[:name], :path => @archetype[:path])
  end
  # initialize Archetype
  def self.init
    # register it
    self.register
    # setup configs
    # locale
    Compass::Configuration.add_configuration_property(:locale, "the user locale") do
      'en_US'
    end
    # locale_aliases
    Compass::Configuration.add_configuration_property(:locale_aliases, "a mapping of locale name aliases") do
      {}
    end
    # reading direction (ltr|rtl)
    Compass::Configuration.add_configuration_property(:reading, "the user interface reading direction") do
      'ltr'
    end
    # environment
    Compass::Configuration.add_configuration_property(:environment, "current environment") do
      :development
    end
    # memoize
    Compass::Configuration.add_configuration_property(:memoize, "should the memoizer be used to improve compilation speed") do
      not (Compass.configuration.environment || :development).to_s.include?('dev')
    end
  end

  def self.name
    @archetype[:name]
  end
end

# init
Archetype.init

# load dependencies
%w(functions sass_extensions).each do |lib|
  require "archetype/#{lib}"
end
