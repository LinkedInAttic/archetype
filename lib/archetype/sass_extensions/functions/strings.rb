require 'archetype/functions/helpers'

#
# This module provides a set of Sass functions for working with Sass::Script::Value::String
#
module Archetype::SassExtensions::Strings
  #
  # replace a substring within a string
  #
  # *Parameters*:
  # - <tt>$haystack</tt> {String} the string to search within
  # - <tt>$needle</tt> {String} the string to match
  # - <tt>$replacement</tt> {String} the string to substitute in
  # - <tt>$all</tt> {Boolean} whether or not to replace all occurances
  # *Returns*:
  # - {String} the string with replaced value
  #
  def str_replace(haystack, needle, replacement, all = false)
    method = all ? :gsub : :sub
    str = helpers.to_str(haystack, ' ', :quotes)
    needle = helpers.to_str(needle, ' ', :quotes)
    replacement = helpers.to_str(replacement, ' ', :quotes)
    str = str.method(method).call(needle, replacement)
    return Sass::Script::Value::String.new(str)
  end
  Sass::Script::Functions.declare :str_replace, [:haystack, :needle, :replacement]
  Sass::Script::Functions.declare :str_replace, [:haystack, :needle, :replacement, :all]

  #
  # given a string and a map of key-values, replace any {key}'s with the associated value
  #
  # *Parameters*:
  # - <tt>$string</tt> {String} the string to subsititute within
  # - <tt>$subsitutions</tt> {Map} the map of key-value pairs to substitute
  # *Returns*:
  # - {String} the string with substituted values
  #
  def str_substitute(string, subsitutions = nil)
    return Sass::Script::Value::String.new('') if string.is_a?(Sass::Script::Value::Null)
    return string if subsitutions.nil?
    subsitutions = subsitutions.to_h
    string = helpers.to_str(string)
    # for each key-value pair...
    subsitutions.each do |key, value|
      # replace all instances of the placeholder `{key}` with the value
      string = string.gsub("{#{key}}", helpers.to_str(value))
    end
    Sass::Script::Value::String.new(string)
  end
  Sass::Script::Functions.declare :str_substitute, [:string]
  Sass::Script::Functions.declare :str_substitute, [:string, :subsitutions]

private
  def helpers
    @helpers ||= Archetype::Functions::Helpers
  end
end
