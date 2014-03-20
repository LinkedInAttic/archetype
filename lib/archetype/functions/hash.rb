%w(shim extend).each do |dep|
  require "archetype/functions/hash/#{dep}"
end