require 'archetype'
require 'archetype-base'
require 'archetype-base-h5bp'
require 'archetype-base-hybrid'
require 'archetype-base-normalize'
require 'archetype-base-reset'
require 'archetype-grid'
require 'archetype-theme'

#
# register as an Archetype extension
#
Archetype::Extensions.register(
  File.basename(__FILE__, '.rb'),
  :path => File.expand_path(File.join(File.dirname(__FILE__), ".."))
)