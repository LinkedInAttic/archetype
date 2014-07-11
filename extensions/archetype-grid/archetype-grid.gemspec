lib = File.expand_path("../../../lib", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "archetype/extensions"

Gem::Specification.new do |gemspec|

  ## Gem Details
  gemspec.summary     = %q{Archetype Grid Extension}
  gemspec.description = %q{An Archetype extension for complex, fixed-width grid based layouts}

  # leverage the Archetype::Extensions::GemspecHelper to extend the gemspec
  Archetype::Extensions::GemspecHelper.new(__FILE__, gemspec)

end
