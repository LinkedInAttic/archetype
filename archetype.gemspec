path = "#{File.dirname(__FILE__)}/lib"
require File.join(path, 'archetype/version')

Gem::Specification.new do |gemspec|
  ## Release Specific Information
  gemspec.version = Archetype::VERSION
  gemspec.date = Date.today

  ## Gem Details
  gemspec.name = 'archetype'
  gemspec.authors = ["Eugene ONeill", "LinkedIn"]
  gemspec.summary = %q{a UI pattern and component library for Compass}
  gemspec.description = %q{UI Pattern and component library for quickly iterating on and maintaining scalable web interfaces}
  gemspec.email = "oneill.eugene@gmail.com"
  gemspec.homepage = "http://www.archetypecss.com/"
  gemspec.license = "Apache License (2.0)"

  ## Paths
  gemspec.require_paths = %w(lib)

  # Gem Files
  gemspec.executables = %w(archetype)
  gemspec.files = %w(LICENSE README.md CHANGELOG.md)
  gemspec.files += Dir.glob("bin/*")
  gemspec.files += Dir.glob("lib/**/*")
  gemspec.files += Dir.glob("stylesheets/**/*")
  gemspec.files += Dir.glob("templates/**/*")
  # test files
  gemspec.files += Dir.glob("test/**/*.*")
  gemspec.files -= Dir.glob("test/fixtures/stylesheets/*/expected/**/*.*")
  gemspec.test_files = Dir.glob("test/**/*.*")
  gemspec.test_files -= Dir.glob("test/fixtures/stylesheets/*/expected/**/*.*")

  ## Gem Bookkeeping
  gemspec.rubygems_version = %q{1.3.6}
  # dependencies
  gemspec.add_dependency('sass',    '>= 3.2', '< 3.3')
  gemspec.add_dependency('compass', '>= 0.12', '< 1.0')
  # required for OrderedHash on Ruby < 1.9
  gemspec.add_dependency('hashery')
end
