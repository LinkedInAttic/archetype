require File.expand_path("../extensions/extension", __FILE__)

Gem::Specification.new do |gemspec|

  # leverage the ArchetypeExtension helper to create a new instance of an extension
  extension = ArchetypeExtension.new(__FILE__)

  ## Release Specific Information
  gemspec.version     = extension.info(:version)

  ## Gem Details
  gemspec.summary     = %q{a UI pattern and component library for Compass}
  gemspec.description = %q{UI Pattern and component library for quickly iterating on and maintaining scalable web interfaces}

  ## most of these are just inheriting from the main archetype.gemspec
  gemspec.name        = extension.info(:name)
  gemspec.authors     = extension.info(:authors)
  gemspec.email       = extension.info(:email)
  gemspec.homepage    = extension.info(:homepage)
  gemspec.license     = extension.info(:license)

  ## Paths
  gemspec.require_paths = %w(lib)

  # Gem Files
  gemspec.files = %w(LICENSE)
  gemspec.files += Dir.glob("#{extension.info(:path)}/**/*")

  # dependencies
  gemspec.add_dependency('archetype', "~> #{Archetype::VERSION}") # assume a dependency on the latest current version of Archetype
end
