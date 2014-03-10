# this is all taken from Compass because they already did the awesome testing framework
require 'test_helper'
require 'compass/logger'
require 'sass/plugin'
require 'archetype'

class ArchetypeTest < MiniTest::Unit::TestCase

  def setup
    Compass.reset_configuration!
  end

  def teardown
    [:archetype].each do |project_name|
      ::FileUtils.rm_rf tempfile_path(project_name)
    end
  end

  SELECTIVE_TESTS = (ENV['ARCHETYPE_TESTS'] and not ENV['ARCHETYPE_TESTS'].empty?) ? ENV['ARCHETYPE_TESTS'].split(',') : nil

  def test_archetype
    ArchetypeTestHelpers::Profiler.start
    # attach a callback to verify each file on save
    Compass.configuration.on_stylesheet_saved do |file|
      file = file.chomp(File.extname(file)).sub(File.join(tempfile_path(@current_project), ''), '')
      assert_renders_correctly file, :ignore_charset => true
    end
    project = compile_project(Archetype.name)
    each_css_file(project.css_path) do |css_file|
      assert_no_errors css_file, Archetype.name
    end
    ArchetypeTestHelpers::Profiler.stop
  end

private
  def assert_no_errors(css_file, project_name)
    file = css_file[(tempfile_path(project_name).size+1)..-1]
    msg = "Syntax Error found in #{file}. Results saved into #{save_path(project_name)}/#{file}"
    assert_equal 0, open(css_file).readlines.grep(/Sass::SyntaxError/).size, msg
  end

  def report_and_fail(name, msg, status = :fail)
    ArchetypeTestHelpers.report status, name
    assert false, msg
  end

  def assert_renders_correctly(*arguments)
    options = arguments.last.is_a?(Hash) ? arguments.pop : {}
    for name in arguments
      actual_result_file = "#{tempfile_path(@current_project)}/#{name}.css"
      expected_result_file = "#{result_path(@current_project)}/#{name}.css"
      unless File.exist?(expected_result_file)
        report_and_fail name, "no expectation set for `#{expected_result_file}`, run `rake test:update` first"
      end
      actual_lines = File.read(actual_result_file)
      actual_lines.gsub!(/^@charset[^;]+;/,'') if options[:ignore_charset]
      actual_lines = actual_lines.split("\n").reject{|l| l=~/\A\Z/}
      expected_lines = ERB.new(File.read(expected_result_file)).result(binding)
      expected_lines.gsub!(/^@charset[^;]+;/,'') if options[:ignore_charset]
      expected_lines = expected_lines.split("\n").reject{|l| l=~/\A\Z/}
      msg = "Error in #{result_path(@current_project)}/#{name}.css\n"
      expected_lines.zip(actual_lines).each_with_index do |pair, line|
        if pair.first == pair.last
          assert true
        else
          msg << diff_as_string(pair.first.inspect, pair.last.inspect)
          # output a prettified diff if we have it
          if defined?(Diffy::Diff)
            begin
              full_diff = Diffy::Diff.new(expected_lines.join("\n"), actual_lines.join("\n")).to_s(:color).gsub(/\n?\\ No newline at end of file/, '')
              msg << "\n\nFull Diff:\n#{'-'*20}\n\n\033[0m#{full_diff}\n\n#{'-'*20}"
            rescue
              # oh well :(
            end
          end
          report_and_fail name, msg
        end
      end
      if expected_lines.size < actual_lines.size
        report_and_fail name, "#{actual_lines.size - expected_lines.size} Trailing lines found in #{actual_result_file}.css: #{actual_lines[expected_lines.size..-1].join('\n')}"
      end
      ArchetypeTestHelpers.report :pass, name
    end
  end

  def within_project(project_name, config_block = nil)
    @current_project = project_name
    Compass.add_configuration(configuration_file(project_name)) if File.exist?(configuration_file(project_name))
    Compass.configuration.project_path = project_path(project_name)
    Compass.configuration.environment = :production
    args = Compass.configuration.to_compiler_arguments(:logger => Compass::NullLogger.new)

    if config_block
      config_block.call(Compass.configuration)
    end



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
