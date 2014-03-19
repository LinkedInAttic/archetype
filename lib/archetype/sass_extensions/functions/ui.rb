module Archetype::SassExtensions::UI; end

%w(glyphs scopes).each do |func|
  require "archetype/sass_extensions/functions/ui/#{func}"
end

module Archetype::SassExtensions::UI
  include Archetype::SassExtensions::UI::Glyphs
  include Archetype::SassExtensions::UI::Scopes
end
