require 'compass'

#
# Initialize Archetype and register it as a Compass extension
#
module Archetype
  NAME = 'archetype'

  # info
  @archetype = {
    :name => NAME,
    :path => File.expand_path(File.join(File.dirname(__FILE__), ".."))
  }

  # initialize Archetype
  def self.init
    ## register it
    register

    ## setup configs
    # locale
    Compass::Configuration.add_configuration_property(:locale, "the user locale") do
      'en_US'
    end
    # locale_aliases
    Compass::Configuration.add_configuration_property(:locale_aliases, "a mapping of locale name aliases") do
      {}
    end
    # environment
    Compass::Configuration.add_configuration_property(:environment, "current environment") do
      :development
    end
    # memoize
    Compass::Configuration.add_configuration_property(:memoize, "should the memoizer be used to improve compilation speed") do
      not (Compass.configuration.environment || :development).to_s.include?('dev')
    end
    # meta
    Compass::Configuration.add_configuration_property(:archetype_meta, "any meta data you want made available to the environment") do
      {}
    end
    # meta
    Compass::Configuration.add_configuration_property(:styleguide_debug, "if true, detailed debugging is turned on for styleguide components") do
      false
    end
  end

  def self.name
    NAME
  end

  private

  ## register as a Compass extension
  def self.register
    Compass::Frameworks.register(NAME, :path => @archetype[:path]);
  end
end

# init
Archetype.init

# load dependencies
%w(extensions functions sass_extensions).each do |lib|
  require "archetype/#{lib}"
end
