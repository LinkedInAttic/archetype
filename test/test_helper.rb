# borrowed from Compass
lib_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(lib_dir) unless $:.include?(lib_dir)
test_dir = File.dirname(__FILE__)
$:.unshift(test_dir) unless $:.include?(test_dir)

require 'compass'
require 'test/unit'
require 'true'

class String
  def name
    to_s
  end
end

%w(diff io test_case).each do |helper|
  require "helpers/#{helper}"
end

class Test::Unit::TestCase
  include Compass::Diff
  include Compass::TestCaseHelper
  include Compass::IoHelper
  extend Compass::TestCaseHelper::ClassMethods
end

module Test
  module Profiler

    ENABLE_GC_STATS = true

    FILE_BASE = "/tmp/artchetype__#{RUBY_VERSION}__#{Archetype::VERSION}"

    if ENV['ARCHETYPE_PROFILER'] and not ENV["CI"]

      # include perftools if profiling
      require 'perftools'

      @allocated_objects_before

      def self.start
        if ENABLE_GC_STATS
          if defined?(GC::Profiler) and GC::Profiler.respond_to?(:enable)
            GC::Profiler.enable
          elsif defined?(GC) and GC.respond_to?(:enable_stats)
            @allocated_objects_before = ObjectSpace.allocated_objects
            GC.enable_stats
            GC.clear_stats if GC.respond_to?(:clear_stats)
          end
        end
        PerfTools::CpuProfiler.start("#{FILE_BASE}.perf")
      end

      def self.stop
        PerfTools::CpuProfiler.stop
        if ENABLE_GC_STATS
          file = File.new("#{FILE_BASE}.gc", "w")
          if defined?(GC::Profiler) and GC::Profiler.respond_to?(:disable)
            GC::Profiler.report file
            GC::Profiler.disable
          elsif defined?(GC) and GC.respond_to?(:disable_stats)
            growth = GC.growth
            collections = GC.collections
            time = GC.time
            mallocs = GC.num_allocations
            allocated_objects = ObjectSpace.allocated_objects - @allocated_objects_before
            file.write("GC growth: #{growth}bcollections: #{collections}, time #{time / 1000000.0}sec, #{mallocs} mallocs, #{allocated_objects} objects created.")
            GC.disable_stats
          end
          file.close
        end
      end
    else
      def self.start
        # do nothing
      end
      def self.stop
        # do nothing
      end
    end
  end
end
