require 'archetype/functions/helpers'

#
# This module provides a set of Sass functions for working with Sass::String
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
    return Sass::Script::String.new(str)
  end
  Sass::Script::Functions.declare :str_replace, [:haystack, :needle, :replacement]
  Sass::Script::Functions.declare :str_replace, [:haystack, :needle, :replacement, :all]

private
  def helpers
    @helpers ||= Archetype::Functions::Helpers
  end
end
