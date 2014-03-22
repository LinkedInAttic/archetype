require 'archetype'

#
# Initialize ArchetypeGrid and register it as a Compass extension
#
module ArchetypeGrid
  NAME = 'archetype-grid'

  # initialize ArchetypeGrid
  def self.init
    # register the extension
    Compass::Frameworks.register(NAME, :path => File.expand_path(File.join(File.dirname(__FILE__), "..")))
  end
end

# init
ArchetypeGrid.init
