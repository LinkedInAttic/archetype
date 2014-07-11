lib = File.expand_path("../../../lib", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "archetype/extensions"

Gem::Specification.new do |gemspec|

  ## Gem Details
  gemspec.summary     = %q{Archetype Normalize.css Extension}
  gemspec.description = %q{An Archetype extension that provides hooks into using Normalize.css' CSS reset}

  # leverage the Archetype::Extensions::GemspecHelper to extend the gemspec
  Archetype::Extensions::GemspecHelper.new(__FILE__, gemspec)

end
