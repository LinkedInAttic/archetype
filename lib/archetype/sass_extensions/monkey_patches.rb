module Archetype
  module Patches
  end
end

%w(handle_include_loop).each do |patch|
  require "archetype/sass_extensions/monkey_patches/#{patch}"
end
