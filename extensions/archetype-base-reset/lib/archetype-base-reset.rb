require 'archetype'

#
# register as an Archetype extension
#
Archetype::Extensions.register(
  File.basename(__FILE__, '.rb'),
  :path => File.expand_path(File.join(File.dirname(__FILE__), ".."))
)
