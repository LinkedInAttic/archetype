require 'archetype'

#
# Initialize ArchetypeTheme and register it as an Archetype extension
#
module ArchetypeTheme
  NAME = 'archetype-theme'

  # initialize ArchetypeTheme
  def self.init
    # register the extension
    Archetype::Extensions.register(NAME, :path => File.expand_path(File.join(File.dirname(__FILE__), "..")))
  end
end

# init
ArchetypeTheme.init
