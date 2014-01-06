require 'archetype/functions/helpers'
require 'archetype/version'
require 'compass/version'
require 'sass/version'

#
# This module provides an interface for testing against various framework version
#
module Archetype::SassExtensions::Version
  # :stopdoc:
  COMPARATOR_PATTERN  = /(\s[neqglt]+\s|[><=!]+)/
  VERSION_PATTERN     = /\d+(\.\d+)*(\.[x|\*])?/
  # :startdoc:

  #
  # get the current version or test against a framework version
  #
  # *Parameters*:
  # - <tt>$test</tt> {String} the test to evalutate
  # *Returns*:
  # - {String|Boolean} if no test or test is just a lookup of a framework, it returns the version of that framework, otherwise it returns the result of the test
  #
  def archetype_version(test = nil)
    test = test.nil? ? Archetype.name : helpers.to_str(test, ' ', :quotes).downcase
    lib = ''
    if test.include?('compass')
      lib = Compass::VERSION
    elsif test.include?('sass')
      lib = Sass::VERSION
    else
      lib = Archetype::VERSION
    end
    # strip off any non-official versioning (e.g. pre/alpha/rc)
    lib = lib.match(VERSION_PATTERN)[0]
    result = compare_version(lib, test.match(VERSION_PATTERN), test.match(COMPARATOR_PATTERN))
    return Sass::Script::Value::String.new(lib) if result.nil?
    return Sass::Script::Bool.new(result)
  end

private
  def helpers
    @helpers ||= Archetype::Functions::Helpers
  end

  #
  # compare a version of a framework
  #
  # *Parameters*:
  # - <tt>$lib</tt> {String} the library (framework) to compare
  # - <tt>$version</tt> {String} the version to compare against
  # - <tt>$comparator</tt> {String} the type of comparison to perform
  # *Returns*:
  # - {Boolean} compare the current framework version against the provided version
  #
  def compare_version(lib, version, comparator)
    return nil if version.nil?
    result = nil
    lib = lib.split('.')
    version = version[0].gsub(/\*/, 'x').split('.')
    # check for wild cards
    wild = version.index('x')
    # check the comparison
    comparator = ((comparator || [])[0] || 'eq').strip
    eq = comparator =~ /(e|=)/
    lt = comparator =~ /(l|<)/
    gt = comparator =~ /(g|>)/
    # if it was wild, substitute it
    version[wild] = lib[wild].to_i + (eq ? 0 : gt ? -1 : 1) if not wild.nil?
    diff = version_value(lib) - version_value(version)
    # check for the version difference
    result = diff > 0 if gt
    result = diff < 0 if lt
    result = diff == 0 if eq and not result
    # if the comparator had an `n` in it, it's a negation
    result = (not result) if comparator =~ /(n|!)/
    return result
  end

  #
  # convert a SemVer string into a numeric value, representing it's weight (lateness)
  #
  # *Parameters*:
  # - <tt>$version</tt> {String} the version string
  # *Returns*:
  # - {Number} a weighted number representing the the version
  #
  def version_value(version)
    sum = 0
    version.each_with_index do |v, i|
      break if v.nil?
      sum += (1000 ** (3 - i)) * v.to_i
    end
    return sum
  end
end
