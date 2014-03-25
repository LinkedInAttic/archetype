module ArchetypeBaseReset

  private

  def self.get_version
    version_file = File.join(File.dirname(__FILE__), "..", "..", "VERSION")
    version = File.read(version_file).strip if File.exist?(version_file)
    version = Archetype::VERSION if (version.nil? or version.empty?) and defined?(Archetype::VERSION)
  end

  public

  VERSION = self.get_version
end
