# :stopdoc:
module Archetype::SassExtensions::Util; end

%w(debug misc images spacing).each do |func|
  require "archetype/sass_extensions/functions/util/#{func}"
end

module Archetype::SassExtensions::Util
  include Archetype::SassExtensions::Util::Misc
  include Archetype::SassExtensions::Util::Images
  include Archetype::SassExtensions::Util::Debug
  include Archetype::SassExtensions::Util::Spacing
end
