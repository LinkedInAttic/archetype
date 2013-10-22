#
# This module provides a set of Sass functions for working with Sass::Script::Value::Number
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
    value = number.value.to_f if number.is_a?(Sass::Script::Value::String)
    value = number.value if number.is_a?(Sass::Script::Value::Number)
    return Sass::Script::Value::Number.new(value)
  end
end
