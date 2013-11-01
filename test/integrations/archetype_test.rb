ENABLE_PROFILER = false
# this is all take from Compass because they already did the awesome testing framework
require 'test_helper'
require 'compass'
require 'compass/logger'
require 'sass/plugin'
require 'fileutils'
require 'perftools' if ENABLE_PROFILER

class ArchetypeTest < Test::Unit::TestCase

  def setup
    Compass.reset_configuration!
  end

  def teardown
    [:archetype].each do |project_name|
      ::FileUtils.rm_rf tempfile_path(project_name)
    end
  end

  def test_archetype
    PerfTools::CpuProfiler.start('tmp/profile') if ENABLE_PROFILER
    within_project('archetype') do |proj|
      each_css_file(proj.css_path) do |css_file|
        assert_no_errors css_file, 'archetype'
      end
      each_sass_file do |sass_file|
        assert_renders_correctly sass_file, :ignore_charset => true
      end
    end
    PerfTools::CpuProfiler.stop if ENABLE_PROFILER
  end

private
  def assert_no_errors(css_file, project_name)
    file = css_file[(tempfile_path(project_name).size+1)..-1]
    msg = "Syntax Error found in #{file}. Results saved into #{save_path(project_name)}/#{file}"
    assert_equal 0, open(css_file).readlines.grep(/Sass::SyntaxError/).size, msg
  end

  def assert_renders_correctly(*arguments)
    options = arguments.last.is_a?(Hash) ? arguments.pop : {}
    for name in arguments
      actual_result_file = "#{tempfile_path(@current_project)}/#{name}.css"
      expected_result_file = "#{result_path(@current_project)}/#{name}.css"
      actual_lines = File.read(actual_result_file)
      actual_lines.gsub!(/^@charset[^;]+;/,'') if options[:ignore_charset]
      actual_lines = actual_lines.split("\n").reject{|l| l=~/\A\Z/}
      expected_lines = ERB.new(File.read(expected_result_file)).result(binding)
      expected_lines.gsub!(/^@charset[^;]+;/,'') if options[:ignore_charset]
      expected_lines = expected_lines.split("\n").reject{|l| l=~/\A\Z/}
      expected_lines.zip(actual_lines).each_with_index do |pair, line|
        if pair.first == pair.last
          assert(true)
        else
          assert false, "Error in #{result_path(@current_project)}/#{name}.css:#{line + 1}\n"+diff_as_string(pair.first.inspect, pair.last.inspect)
        end
      end
      if expected_lines.size < actual_lines.size
        assert(false, "#{actual_lines.size - expected_lines.size} Trailing lines found in #{actual_result_file}.css: #{actual_lines[expected_lines.size..-1].join('\n')}")
      end
    end
  end

  def within_project(project_name, config_block = nil)
    @current_project = project_name
    Compass.add_configuration(configuration_file(project_name)) if File.exists?(configuration_file(project_name))
    Compass.configuration.project_path = project_path(project_name)
    Compass.configuration.environment = :production
    args = Compass.configuration.to_compiler_arguments(:logger => Compass::NullLogger.new)

    if config_block
      config_block.call(Compass.configuration)
    end

    if Compass.configuration.sass_path && File.exists?(Compass.configuration.sass_path)
      compiler = Compass::Compiler.new *args
      compiler.clean!
      compiler.run
    end
    yield Compass.configuration if block_given?
  rescue
    save_output(project_name)
    raise
  end

  def each_css_file(dir, &block)
    Dir.glob("#{dir}/**/*.css").each(&block)
  end

  def each_sass_file(sass_dir = nil)
    sass_dir ||= template_path(@current_project)
    Dir.glob("#{sass_dir}/**/[^_]*.s[ac]ss").each do |sass_file|
      yield sass_file[(sass_dir.length+1)..-6]
    end
  end

  def save_output(dir)
    FileUtils.rm_rf(save_path(dir))
    FileUtils.cp_r(tempfile_path(dir), save_path(dir)) if File.exists?(tempfile_path(dir))
  end

  def project_path(project_name)
    absolutize("fixtures/stylesheets/#{project_name}")
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

end
