lib = File.expand_path("../../../lib", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "archetype/extensions"

Gem::Specification.new do |gemspec|

  ## Gem Details
  gemspec.summary     = %q{Archetype bundled version of Archetype Core and all official extensions}
  gemspec.description = %q{An Archetype bundle that includes the official extensions}

  # leverage the Archetype::Extensions::GemspecHelper to extend the gemspec
  Archetype::Extensions::GemspecHelper.new(__FILE__, gemspec)

  # add additional dependencies on the other extensions
  extensions_dir = File.expand_path("../../", __FILE__)
  excluded_dirs = ['.', '..', File.basename(__FILE__, '.gemspec').strip]
  deps = Dir.entries(extensions_dir) - excluded_dirs
  deps.each do |dep|
    # TODO - this needs to respect individual extension versions, but we don't have those yet
    gemspec.add_dependency(dep, "~> #{Archetype::VERSION}")
  end
end
