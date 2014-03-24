require 'test_helper'
require 'compass/logger'
require 'sass/plugin'
require 'archetype'

require 'colorize'

require 'integrations/helpers'

class ArchetypeTest < MiniTest::Unit::TestCase

  def setup
    Compass.reset_configuration!
  end

  def test_archetype
    ArchetypeTestHelpers::Profiler.start
    # with each project in the fixtures directory
    with_each_project do |project_name|

      # compile the project (each file is verified by `assert_on_stylesheet_saved`)
      compile_project(project_name) do |project|
        # then, after the scss files have been compiled and verified...

        # make sure there are no errors
        each_css_file(project.css_path) do |file|
          assert_no_errors file, Archetype.name
        end

        # and no missing expectations
        @current_file_update = :removed
        each_css_file(expectation_path) do |file|
          name = get_relative_file_name(file, expectation_path)
          next unless is_test_selected(name)
          unless File.exist?(File.join(project.css_path, "#{name}.css"))
            assert_no_css_diff(File.read(file), '', name, "#{name}.css was not created!")
          end
        end

        # after it's all done...
        update_expectations if UPDATING_TESTS
      end

    end
    ArchetypeTestHelpers::Profiler.stop
  end

  def assert_on_stylesheet_saved
    # attach a callback to verify each file on save
    Compass.configuration.on_stylesheet_saved do |file|
      # get the files relative path
      file = get_relative_file_name(file, Compass.configuration.css_path)
      # assert that everything rendered correctly
      assert_renders_correctly file
    end
  end
end
