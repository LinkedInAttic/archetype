lib = File.expand_path("../../../lib", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "archetype/extensions"

Gem::Specification.new do |gemspec|

  # leverage the Archetype::Extensions::GemspecHelper to create a new instance of an extension
  extension = Archetype::Extensions::GemspecHelper.new(__FILE__)

  ## Release Specific Information
  gemspec.version     = extension.info(:version)

  ## Gem Details
  gemspec.summary     = %q{Archetype Theme Extension}
  gemspec.description = %q{An Archetype extension that provides several off-the-shelf UI components}

  ## most of these are just inheriting from the main archetype.gemspec
  gemspec.name        = extension.info(:name)
  gemspec.authors     = extension.info(:authors)
  gemspec.email       = extension.info(:email)
  gemspec.homepage    = File.join(extension.info(:homepage), 'extensions', extension.info(:name))
  gemspec.license     = extension.info(:license)

  ## Paths
  gemspec.require_paths = %w(lib)

  # Gem Files
  # by default, include everything but the gemspec
  gemspec.files = Dir.glob("**/*") - Dir.glob("**/*.gemspec")

  # dependencies
  gemspec.add_dependency('archetype', "~> #{Archetype::VERSION}") # assume a dependency on the latest current version of Archetype
end
