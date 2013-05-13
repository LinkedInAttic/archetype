module Archetype
  module Version
    #
    # Returns a string representing the version.
    #
    # The :major, :minor, and :teeny keys have their respective numbers.
    # The :string key contains a human-readable string representation of the version.
    # The :rev key will have the current revision hash.
    #
    # Method borrowed from Compass. All credit goes to Chris Eppstein and other contributors
    # https://github.com/chriseppstein/compass/blob/stable/lib/compass/version.rb
    # \(This method swiped from Haml and then modified, some credit goes to Nathan Weizenbaum\)
    #
    # *Returns*:
    # - {String} the version of Archetype
    #
    def version
      if defined?(@version)
        @version
      else
        read_version
      end
    end

  protected
    def scope(file) # :nodoc:
      File.join(File.dirname(__FILE__), '..', '..', file)
    end

    def read_version
      require 'yaml'
      begin
        @version = YAML.load(File.read(scope('VERSION.yml')))
        @version[:teeny] = @version[:patch]
        @version[:string] = "#{@version[:major]}.#{@version[:minor]}"
        @version[:string] << ".#{@version[:patch]}" if @version[:patch]
        @version[:string] << ".#{@version[:build]}" if @version[:build]
        @version[:string] << ".#{@version[:state]}" if @version[:state]
        @version[:string] << ".#{@version[:iteration]}" if @version[:iteration]
        if !ENV['OFFICIAL'] && r = revision
          @version[:string] << ".#{r[0..6]}"
          @version[:rev] = r
        end
        return @version
      rescue
        # this is a hack, but I'm not fully understanding how to fix this correctly
        # see issue #4
        # if it failed, try again, for now
        return read_version
      end
    end

    def revision
      revision_from_git
    end

    def revision_from_git
      if File.exists?(scope('.git/HEAD'))
        Dir.chdir scope(".") do
          `git rev-parse HEAD`
        end
      end
    end
  end

  extend Archetype::Version
  def self.const_missing(const)
    # This avoid reading from disk unless the VERSION is requested.
    if const == :VERSION
      version[:string]
    else
      super
    end
  end
end