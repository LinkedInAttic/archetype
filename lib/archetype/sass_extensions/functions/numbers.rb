#
# This module provides a set of Sass functions for working with Sass::Number
#
module Archetype::SassExtensions::Numbers
  #
  # remove the units from a number
  #
  # *Parameters*:
  # - <tt>$number</tt> {Number} the number to remove units from
  # *Returns*:
  # - {Number} the number without units
  #
  def strip_units(number)
    value = 0
    value = number.value.to_f if number.is_a?(Sass::Script::String)
    value = number.value if number.is_a?(Sass::Script::Number)
    return Sass::Script::Number.new(value)
  end
end
