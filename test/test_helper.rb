# borrowed from Compass
lib_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(lib_dir) unless $:.include?(lib_dir)
test_dir = File.dirname(__FILE__)
$:.unshift(test_dir) unless $:.include?(test_dir)

require 'rubygems'
require 'compass'
require 'test/unit'

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
