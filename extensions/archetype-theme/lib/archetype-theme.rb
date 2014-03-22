require 'archetype'

#
# Initialize ArchetypeTheme and register it as a Compass extension
#
module ArchetypeTheme
  NAME = 'archetype-theme'

  # initialize ArchetypeTheme
  def self.init
    # register the extension
    Compass::Frameworks.register(NAME, :path => File.expand_path(File.join(File.dirname(__FILE__), "..")))
  end
end

# init
ArchetypeTheme.init
