description = "Check a set of files for migration and back-compat issues"
if @description.nil?
  DELIMITER = "\n  "
  DATA = {
    '0.0.2.alpha.1' => {
      :notice => %q{Archetype now requires Sass 3.3+ and Compass 0.13+},
      :tests => {
        :sacss => [
          {
            :pattern => /(gradient-with-deg|_isLegacySupported)/m,
            :message => 'mixin or function `$1` has been removed'
          },
          {
            :pattern => /(?:styleguide-(?:add|extend)-component)[^\;]*(inline-block)(?:\s+|\:)true/m,
            :message => '`inline-block` has changed syntax'
          },
          {
            :pattern => /(?:styleguide-(?:add|extend)-component)[^\;]*\s+\(?(gradient)(?:\s|\:)/m,
            :message => 'use `background-image` instead of `$1`'
          },
          {
            :pattern => /(\$CONFIG_(?:STATE_MAPPINGS|BROWSER_VENDORS_HACK|OS_VENDORS_CLASS|SAFE_FONTS|LOADERS))\s*\:\s*\(\s*[^\:]+\s*\)(?: \!default)?\;/m,
            :message => '`$1` is now a map structure instead of lists'
          },
          {
            :pattern => /(?:(?:nth(?:-cyclic)?|associative)\s*\(\s*)(\$CONFIG_(?:STATE_MAPPINGS|BROWSER_VENDORS_HACK|OS_VENDORS_CLASS|SAFE_FONTS|LOADERS))/m,
            :message => '`$1` is now a map structure instead of lists'
          },
          {
            :pattern => /(\$CONFIG_GLYPHS_(?:NAME|VERSION|SVG_ID|BASE_PATH|EOT|FILES|THRESHOLD|MAPPINGS))/m,
            :message => '`$1` is deprecated, use `$CORE_GLYPHS_LIBRARIES` instead'
          },
        ],
        :rb => [],
        :scss => [],
        :sass => []
      }
    }
  }

  options = {
    :from => ''
  }
  OptionParser.new do |opts|
    opts.banner = description
    opts.define_head "Usage: archetype migrate [path] [options]"
    opts.separator ""
    opts.separator "Example usage:"
    opts.separator " archetype migrate /path/to/scss/ --from=0.0.1.alpha"

    opts.on('-f', '--from VERSION', 'Archetype version migrating from') do |v|
      options[:from] = v
    end

    opts.on('-h', '--help', 'shows this help message') do
      puts opts
      exit
    end

    if not @help.nil?
      puts opts
      exit
    end
  end.parse!

  base = ARGV[1] || '.'
  count = 0
  files = {}
  DATA.each do |version, obj|
    if version > options[:from]
      messages = []
      messages << obj[:notice] if not obj[:notice].nil?
      obj[:tests].each do |category, tests|
        if not tests.nil? and not tests.empty?
          ext = case category
          when :rb
            '.rb'
          when :sass
            '.sass'
          when :scss
            '.scss'
          when :all
            ''
          else
            '.s[a|c]ss'
          end

          Dir.glob(File.join(base, '**', "*#{ext}")) do |file|
            contents = files[file]
            message = []

            tests.each do |test|
              if contents.nil?
                contents = ''
                File.readlines(file).select do |line|
                  # strip off the comments and push it onto the contents
                  contents << line.gsub(/\s*((\/\/.*)|(\/\*(?!\*\/)?\*\/))/, '')
                end
                # cache the contents so we don't have to read it in again
                files[file] = contents
              end

              if contents =~ test[:pattern]
                contents.scan(test[:pattern]).each do |match|
                  message << test[:message].gsub('$1', match[0])
                  count += 1
                end
              end

            end

            if not message.empty?
              messages << "#{file}:#{DELIMITER}#{message.join(DELIMITER)}"
            end
          end
        end
      end
      if not messages.empty?
        puts "#{'='*20}\nv#{version}\n#{'-'*20}\n#{messages.join("\n\n")}"
      end
    end
  end

  if count > 0
    puts "\n#{count} backward compatibility issues found!"
  else
    puts "\neverything else looks good!"
  end
  exit
else
  @description = description
end
