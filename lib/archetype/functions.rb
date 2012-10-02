# :stopdoc:
# Load necessary functions.
#
module Archetype::Functions
end

%w(hash helpers styleguide_memoizer).each do |dep|
  require "archetype/functions/#{dep}"
end
