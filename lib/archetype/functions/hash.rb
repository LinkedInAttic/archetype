%w(extend shim).each do |dep|
  require "archetype/functions/hash/#{dep}"
end