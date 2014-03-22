class ArchetypeExtension

  def initialize(name)

    e = @extension = {}
    # we only care about the name, so strip off anything if we were given a file/path
    e[:name] = File.basename(name, '.gemspec').strip
    # the path to the extension
    e[:path] = File.expand_path("../#{e[:name]}/", __FILE__)
    # the lib directory within the extension
    e[:lib]  = File.join(e[:path], 'lib')

    resolve_version
  end

  def info(prop)
    return @extension[prop] || core.send(prop)
  end

  private

  def resolve_version
    # if a version.rb file exists within the extension, we'll get the version from that
    version_rb = "#{@extension[:lib]}/#{@extension[:name]}/version.rb"
    require version_rb if File.exist?(version_rb)
    @extension[:version] = version_const if defined?(version_const)
    # if the version isn't set, use Archetype's core version
    @extension[:version] = core.version if @extension[:version].nil? or @extension[:version].empty?
  end

  def version_const
    # converts the hyphenated name to a module
    name = @extension[:name].gsub(/(?<=_|\-|^)(\w)/){$1.upcase}.gsub(/(?:_|-)(\w)/,'\1')
    begin
      return Module.const_get("#{name}::VERSION")
    rescue NameError
      return nil
    end
  end

  def core
    @default ||= Gem::Specification.load('archetype.gemspec')
  end

end