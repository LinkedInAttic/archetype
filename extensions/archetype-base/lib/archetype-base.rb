require 'archetype'

#
# Initialize ArchetypeBase and register it as a Compass extension
#
module ArchetypeBase
  NAME = 'archetype-base'

  # initialize ArchetypeBase
  def self.init
    # register the extension
    Compass::Frameworks.register(NAME, :path => File.expand_path(File.join(File.dirname(__FILE__), "..")))
  end
end

# init
ArchetypeBase.init
