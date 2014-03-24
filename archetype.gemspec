lib = File.expand_path("../lib", __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'archetype/version'

Gem::Specification.new do |gemspec|
  ## Release Specific Information
  gemspec.version = Archetype::VERSION

  ## Gem Details
  gemspec.name = 'archetype'
  gemspec.authors = ["Eugene ONeill", "LinkedIn"]
  gemspec.summary = %q{A CSS UI Component Authoring Framework}
  gemspec.description = %q{
    Archetype is a Compass/Sass based framework for authoring configurable,
    composable UI components and patterns. The natural language syntax that
    Archetype provides allows your designers and developers to discuss UI
    compositions using the same vocabulary.
  }
  gemspec.email = "oneill.eugene@gmail.com"
  gemspec.homepage = "http://www.archetypecss.com/"
  gemspec.license = "Apache License (2.0)"

  ## Paths
  gemspec.require_paths = %w(lib)

  # Gem Files
  gemspec.files = `git ls-files`.split($/).select {|f| File.exist?(f) && f =~ %r{^(lib|stylesheets|templates)/} }
  gemspec.files += %w(LICENSE README.md CHANGELOG.md VERSION)

  gemspec.executables = gemspec.files.grep(%r{^bin/}) { |f| File.basename(f) }

  ## Gem Bookkeeping
  gemspec.rubygems_version = %q{1.3.6}
  # dependencies
  gemspec.add_dependency('compass',   '~> 1.0.0.alpha.19')
  gemspec.add_dependency('sass',      '~> 3.3')
  # required for OrderedHash on Ruby < 1.9
  gemspec.add_dependency('hashery',   '~> 2.1')
end
