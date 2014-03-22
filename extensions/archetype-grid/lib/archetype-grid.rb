require 'archetype'

#
# Initialize ArchetypeGrid and register it as an Archetype extension
#
module ArchetypeGrid
  NAME = 'archetype-grid'

  # initialize ArchetypeGrid
  def self.init
    # register the extension
    Archetype::Extensions.register(NAME, :path => File.expand_path(File.join(File.dirname(__FILE__), "..")))
  end
end

# init
ArchetypeGrid.init
