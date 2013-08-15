require 'fileutils'
description = "Generate a new Archetype theme"

if @description.nil?
  options = {
    :extends => 'archetype'
  }
  OptionParser.new do |opts|
    opts.banner = description
    opts.define_head "Usage: archetype theme [path] [options]"
    opts.separator ""
    opts.separator "Example usage:"
    opts.separator " archetype theme /path/to/scss/ --name=myCustomTheme"
    opts.separator " archetype theme --name=themes/myExtendedTheme --extends=themes/myBaseTheme"

    opts.on('-n', '--name THEME', 'theme name') do |v|
      options[:theme] = v
    end

    opts.on('-x', '--extends THEME', 'theme name to extend') do |v|
      options[:extends] = v
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

  if not options[:theme].nil?
    base = ARGV[1] || '.'
    tmp = '/tmp/theme_' + rand(36**8).to_s(36)
    theme_template = File.join(File.dirname(__FILE__), '../../../templates/_theme/')
    theme_path = File.join(base, options[:theme])
    extends = "#{options[:extends]}"
    if options[:extends] != 'archetype'
      extends = "#{extends}/core"
    end
    theme_name = File.basename(options[:theme])
    # copy template files to tmp dir
    FileUtils.mkdir_p(tmp)
    FileUtils.cp_r(Dir["#{theme_template}/**"], tmp)

    puts "Creating theme '#{theme_name}' in #{File.expand_path(theme_path)}..."
    puts "extending from #{options[:extends]}" if options[:extends] != 'archetype'

    # update all placeholders in template files
    Dir.glob("#{tmp}/**/*.scss") do |filename|
      out = File.read(filename).gsub(/__THEME_NAME__/, theme_name).gsub(/__THEME_EXTENDS__/, extends)
      File.open(filename, "w") { |file| file.puts out }
    end

    # now move all the theme files to their destination
    FileUtils.mkdir_p(theme_path)
    FileUtils.cp_r(Dir["#{tmp}/**"], theme_path)

    # create convenience file _<theme>.scss ...
    File.open(File.join(File.dirname(theme_path), "_#{theme_name}.scss"), "w") { |file| file.puts "// #{theme_name} theme\n@import \"#{theme_name}/core\";\n" }

    # remove tmp dir
    FileUtils.rm_rf(tmp)
    puts "Congratulations! Your new theme has been created!"
    puts "Use @import \"#{options[:theme]}\" in your scss files."
    exit
  end
else
  @description = description
end
