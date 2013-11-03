%w(lists strings styleguide ui locale numbers version environment util).each do |func|
  require "archetype/sass_extensions/functions/#{func}"
end

# :stopdoc:
module Sass::Script::Functions
  include Archetype::SassExtensions::Util
  include Archetype::SassExtensions::Lists
  include Archetype::SassExtensions::Strings
  include Archetype::SassExtensions::Styleguide
  include Archetype::SassExtensions::UI
  include Archetype::SassExtensions::Locale
  include Archetype::SassExtensions::Numbers
  include Archetype::SassExtensions::Version
  include Archetype::SassExtensions::Environment
end
