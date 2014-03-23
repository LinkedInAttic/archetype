# this is all taken from Compass because they already did the awesome testing framework
require 'test_helper'
require 'compass/logger'
require 'sass/plugin'
require 'archetype'

require 'colorize'

unless ENV['CI']
  require 'fileutils'
end

class ArchetypeTest < MiniTest::Unit::TestCase

  def setup
    Compass.reset_configuration!
  end

  def teardown
    [:archetype].each do |project_name|
      ::FileUtils.rm_rf tempfile_path(project_name)
    end
  end

  UPDATING_TESTS = ENV['UPDATING_TESTS'] and not ENV['UPDATING_TESTS'].empty? and not ENV['CI']
  FAIL_STATUS = UPDATING_TESTS ? :skip : :fail
  SELECTIVE_TESTS = (ENV['ARCHETYPE_TESTS'] and not ENV['ARCHETYPE_TESTS'].empty? and not ENV['CI']) ? ENV['ARCHETYPE_TESTS'].split(',') : nil

  def test_archetype
    ArchetypeTestHelpers::Profiler.start
    # attach a callback to verify each file on save
    Compass.configuration.on_stylesheet_saved do |file|
      file = get_relative_file_name(file, tempfile_path(@current_project))
      assert_renders_correctly file
    end

    # for each project in the fixtures directory
    Dir.glob(File.join(all_projects_path, '*')).each do |name|

      project = compile_project(File.basename(name))
      each_css_file(project.css_path) do |file|
        assert_no_errors file, Archetype.name
      end
      each_css_file(result_path(@current_project)) do |file|
        name = get_relative_file_name(file, result_path(@current_project))
        unless File.exist?(File.join(tempfile_path(@current_project), "#{name}.css"))
          @current_file_update = :removed
          assert_no_css_diff(File.read(file), '', name)
        end
      end

      # after it's all done...
      update_expectations if UPDATING_TESTS
    end
    ArchetypeTestHelpers::Profiler.stop
  end

private
  def assert_no_errors(css_file, project_name)
    file = css_file[(tempfile_path(project_name).size+1)..-1]
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
      actual_result_file = File.join(tempfile_path(@current_project), "#{name}.css")
      expected_result_file = File.join(result_path(@current_project), "#{name}.css")

      results_exist = File.exist?(expected_result_file)

      unless UPDATING_TESTS || results_exist
        report_and_fail name, "no expectation set for `#{expected_result_file}`, run `rake test:update` first"
      end

      actual_result = File.read(actual_result_file)
      expected_result = results_exist ? File.read(expected_result_file) : ''

      @current_file_update = results_exist ? :updated : :added

      assert_no_css_diff(expected_result, actual_result, name, "Error in #{result_path(@current_project)}/#{name}.css\n")

      ArchetypeTestHelpers.report :pass, name
    end
  end

  def within_project(project_name, config_block = nil)
    @current_project = project_name
    config = configuration_file(project_name)
    msg = ["\nCompiling project #{project_name.colorize(:cyan)}"]
    if File.exist?(config)
      Compass.add_configuration(config)
      msg << "with configuration file: #{config.split('/').slice(-2..-1).join('/')}"
    end

    puts "#{msg.join(' ')}..."

    Compass.configuration.project_path = project_path(project_name)
    Compass.configuration.environment = :production
    args = Compass.configuration.to_compiler_arguments(:logger => Compass::NullLogger.new)

    require File.expand_path(File.join(
      File.dirname(__FILE__), '..', '..',
      'extensions', project_name,
      'lib', project_name
    )) if project_name.include?('-')

    system "cd #{project_path(project_name)} && compass install #{project_name} -c #{config}"


    config_block.call(Compass.configuration) if config_block

    if Compass.configuration.sass_path && File.exist?(Compass.configuration.sass_path)
      compiler = Compass::Compiler.new *args
      compiler.clean!
      if SELECTIVE_TESTS
        each_sass_file do |name, path|
          next unless SELECTIVE_TESTS.include?(name)
          dest = File.join(Compass.configuration.css_path, "#{name}.css")
          FileUtils.mkdir_p(File.dirname(dest))
          compiler.compile(path, dest)
        end
      else

        compiler.run

      end
    end


    return Compass.configuration
  rescue
    save_output(project_name)
    raise
  end

  alias_method :compile_project, :within_project

  def each_css_file(dir, &block)
    Dir.glob("#{dir}/**/*.css").each(&block)
  end

  def each_sass_file(sass_dir = nil)
    sass_dir ||= template_path(@current_project)
    Dir.glob("#{sass_dir}/**/[^_]*.s[ac]ss").each do |sass_file|
      yield(sass_file[(sass_dir.length+1)..-6], sass_file)
    end
  end

  def save_output(dir)
    FileUtils.rm_rf(save_path(dir))
    FileUtils.cp_r(tempfile_path(dir), save_path(dir)) if File.exist?(tempfile_path(dir))
  end

  def all_projects_path
    absolutize("fixtures/stylesheets")
  end

  def project_path(project_name)
    File.join(all_projects_path, project_name.to_s)
  end

  def configuration_file(project_name)
    File.join(project_path(project_name), "config.rb")
  end

  def tempfile_path(project_name)
    File.join(project_path(project_name), "tmp")
  end

  def template_path(project_name)
    File.join(project_path(project_name), "source")
  end

  def result_path(project_name)
    File.join(project_path(project_name), "expected")
  end

  def save_path(project_name)
    File.join(project_path(project_name), "saved")
  end

  def assert_no_css_diff(expected, actual, name, msg = nil)
    begin
      diff = Diffy::Diff.new(cleanup_css(expected), cleanup_css(actual))
      # if there are any lines that were additions or deletions...
      if diff.select { |line| line =~ /^[\+\-]/ }.any?
        # get the full diff, colorize it, and strip out newline warnings
        diff = diff.to_s(:color).gsub(/\n?\\ No newline at end of file/, '').strip
        msg = UPDATING_TESTS ? "#{name}.css has been #{colorize_expection_update}" : msg || ''
        report_and_fail name, "\n#{msg}\n#{'-'*20}\n#{diff}\n#{'-'*20}"
      end
    rescue Errno::EBADF => e # rescue from JRuby's `Bad file descriptor` (see https://github.com/samg/diffy/issues/36)
      sleep(0.05) # sleep for 50ms
      assert_no_css_diff(expected, actual, name, msg) # and try again
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

  def update_expectations
    checkmark = "\u2713 "
    if @updated_tests.nil? or @updated_tests.empty?
      puts "\n#{checkmark}Cool! Looks like all the tests are up to date for #{@current_project}".colorize(:green)
    else
      puts "\n\nThe following tests have been updated for #{@current_project}:".colorize(:yellow)
      @updated_tests.each do |test|
        puts " - #{test[:name]} (#{colorize_expection_update(test[:type])})"
      end
      puts "Are all of these changes expected? [y/n]".colorize(:yellow)
      if (($stdin.gets.chomp)[0] == 'y')
        FileUtils.rm_rf(File.join(result_path(@current_project), '.'))
        FileUtils.cp_r(File.join(tempfile_path(@current_project), '.'), File.join(result_path(@current_project)))
        puts "#{checkmark}Thanks! The test expectations for #{@current_project} have been updated".colorize(:green)
      else
        puts "Please manually update the test cases and expectations for #{@current_project}".colorize(:red)
      end
    end
  end

end
