class ArchetypeTest < MiniTest::Unit::TestCase
  private

  UPDATING_TESTS = ENV['UPDATING_TESTS'] and not ENV['UPDATING_TESTS'].empty? and not ENV['CI']
  FAIL_STATUS = UPDATING_TESTS ? :skip : :fail
  SELECTIVE_TESTS = (ENV['ARCHETYPE_TESTS'] and not ENV['ARCHETYPE_TESTS'].empty? and not ENV['CI']) ? ENV['ARCHETYPE_TESTS'].split(',') : nil

  def assert_no_errors(css_file, project_name)
    file = css_file[(css_path(project_name).size+1)..-1]
    msg = "Syntax Error found in #{file}. Results saved into #{save_path(project_name)}/#{file}"
    assert_equal 0, open(css_file).readlines.grep(/Sass::SyntaxError/).size, msg
  end

  def report_and_fail(name, msg, status = FAIL_STATUS)
    ArchetypeTestHelpers.report status, name
    if UPDATING_TESTS
      record_updated_test name, msg
    else
      assert false, msg
    end
  end

  def record_updated_test(name, msg)
    (@updated_tests ||= []) << {
      :name => name,
      :type => @current_file_update
    }
    puts msg
  end

  def assert_renders_correctly(*arguments)
    options = arguments.last.is_a?(Hash) ? arguments.pop : {}
    for name in arguments
      actual_result_file = File.join(css_path, "#{name}.css")
      expected_result_file = File.join(expectation_path, "#{name}.css")

      results_exist = File.exist?(expected_result_file)

      unless UPDATING_TESTS || results_exist
        report_and_fail name, "no expectation set for `#{expected_result_file}`, run `rake test:update` first"
      end

      actual_result = File.read(actual_result_file)
      expected_result = results_exist ? File.read(expected_result_file) : ''

      @current_file_update = results_exist ? :updated : :added

      assert_no_css_diff(expected_result, actual_result, name, "Error in #{expectation_path}/#{name}.css\n")

      ArchetypeTestHelpers.report :pass, name
    end
  end

  def compile_project(project_name, config_block = nil)
    @current_project = project_name
    with_each_configuration_file do |config|

      cleanup_project_space!

      add_config_default(:expected_dir, 'expected')

      msg = ["\nCompiling project #{project_name.colorize(:cyan)}"]
      if File.exist?(config)
        Compass.add_configuration(config)
        msg << "with configuration #{config.split('/').slice(-2..-1).join('/').colorize(:cyan)}"
      end

      puts "#{msg.join(' ')}..."

      assert_on_stylesheet_saved

      Compass.configuration.project_path = project_path(project_name)
      Compass.configuration.environment = :production
      args = Compass.configuration.to_compiler_arguments(:logger => Compass::NullLogger.new)

      install_extension_with_config(project_name, config)

      config_block.call(Compass.configuration) if config_block

      if Compass.configuration.sass_path && File.exist?(Compass.configuration.sass_path)
        compiler = Compass::Compiler.new *args
        compiler.clean!
        if SELECTIVE_TESTS
          each_sass_file do |name, path|
            next unless is_test_selected(name)
            dest = File.join(Compass.configuration.css_path, "#{name}.css")
            FileUtils.mkdir_p(File.dirname(dest))
            compiler.compile(path, dest)
          end
        else
          compiler.run
        end
      end

      yield(Compass.configuration) if block_given?

      cleanup_project_space!
      reset!
    end
  rescue
    save_output(project_name)
    raise
  end

  def each_css_file(dir, &block)
    Dir.glob("#{dir}/**/*.css").each(&block)
  end

  def each_sass_file(sass_dir = nil)
    sass_dir ||= template_path
    Dir.glob("#{sass_dir}/**/[^_]*.s[ac]ss").each do |sass_file|
      yield(sass_file[(sass_dir.length+1)..-6], sass_file)
    end
  end

  def save_output(dir)
    FileUtils.rm_rf(save_path(dir))
    FileUtils.cp_r(css_path(dir), save_path(dir)) if File.exist?(css_path(dir))
  end

  def with_each_project
    @all_projects ||= Dir.glob(File.join(all_projects_path, '*'))
    @all_projects.each do |name|
      yield(File.basename(name)) if block_given?
    end
  end

  def with_each_configuration_file
    configs = Dir.glob(File.join(project_path, 'config*.rb'))
    configs = ['config_none.rb'] if configs.empty?
    configs.each do |config|
      yield(config) if block_given?
    end
  end

  def all_projects_path
    absolutize("fixtures/stylesheets")
  end

  def project_path(project_name = @current_project)
    File.join(all_projects_path, project_name.to_s)
  end

  def css_path(project_name = @current_project)
    File.join(project_path(project_name), Compass.configuration.css_dir)
  end

  def assets_path(project_name = @current_project)
    File.join(project_path(project_name), "assets")
  end

  def template_path(project_name = @current_project)
    File.join(project_path(project_name), Compass.configuration.sass_dir)
  end

  def expectation_path(project_name = @current_project)
    File.join(project_path(project_name), Compass.configuration.expected_dir)
  end

  def save_path(project_name = @current_project)
    File.join(project_path(project_name), "saved")
  end

  def is_test_selected(name)
    return true unless SELECTIVE_TESTS
    SELECTIVE_TESTS.select {|t| return true if File.join(@current_project, name).include?(t)}
    return false
  end

  def assert_no_css_diff(expected, actual, name, msg = nil)
    with_new_diff(cleanup_css(expected), cleanup_css(actual)) do |diff|
      # if there are any lines that were additions or deletions...
      if diff.select { |line| line =~ /^[\+\-]/ }.any?
        # get the full diff, colorize it, and strip out newline warnings
        diff = diff.to_s(:color).gsub(/\n?\\ No newline at end of file/, '').strip
        msg = UPDATING_TESTS ? "#{name}.css has been #{colorize_expection_update}" : msg || ''
        report_and_fail name, "\n#{msg}\n#{'-'*20}\n#{diff}\n#{'-'*20}"
      end
    end
  end

  def cleanup_css(css)
    return css.strip.gsub(/^@charset[^;]+;/,'').strip
  end

  def colorize_expection_update(type = @current_file_update)
    colors = {
      :added    => :green,
      :removed  => :red,
      :updated  => :cyan
    }
    return type.to_s.colorize(colors[type])
  end

  def get_relative_file_name(file, path)
    return file.chomp(File.extname(file)).sub(File.join(path, ''), '')
  end

  def install_extension_with_config(extension, config)
    require File.expand_path(File.join(
      File.dirname(__FILE__), '..', '..',
      'extensions', extension,
      'lib', extension
    )) unless extension == 'archetype'

    compass_install = "cd #{project_path(extension)} && compass install #{extension}"
    compass_install << " -c #{config}" if File.exist?(config)
    system compass_install
  end

  def update_expectations
    checkmark = "\u2713 "
    if @updated_tests.nil? or @updated_tests.empty?
      puts "\n#{checkmark}Cool! Looks like all the tests are up to date for #{@current_project}".colorize(:green)
    else
      puts "\n\nThe following tests have been updated for #{@current_project}:".colorize(:yellow)
      @updated_tests.each do |test|
        puts " - #{test[:name]} (#{colorize_expection_update(test[:type])})"
      end
      @updated_tests = nil
      puts "Are all of these changes expected? [y/n]".colorize(:yellow)
      if (($stdin.gets.chomp)[0] == 'y')
        FileUtils.rm_rf(File.join(expectation_path, '.'))
        FileUtils.cp_r(File.join(css_path, '.'), File.join(expectation_path))
        puts "#{checkmark}Thanks! The test expectations for #{@current_project} have been updated".colorize(:green)
      else
        puts "Please manually update the test cases and expectations for #{@current_project}".colorize(:red)
      end
    end
  end

  def cleanup_project_space!
    ::FileUtils.rm_rf css_path
    ::FileUtils.rm_rf assets_path
  end

  def reset!
    ::Archetype::SassExtensions::Styleguide.reset!
    ::Archetype::Functions::StyleguideMemoizer.reset!
    Compass.reset_configuration!
  end

  def with_new_diff(*arguments)
    begin
      yield Diffy::Diff.new(*arguments) if block_given?
    rescue Errno::EBADF => e # rescue from JRuby's `Bad file descriptor` (see https://github.com/samg/diffy/issues/36)
      sleep(0.05) # sleep for 50ms
      send(__method__, *arguments) # and try again
    end
  end

  def add_config_default(property, default)
    Compass::Configuration.add_configuration_property(:expected_dir, "config for #{property.to_s}") do
      default
    end
  end
end
