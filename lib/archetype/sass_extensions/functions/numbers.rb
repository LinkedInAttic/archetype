#
# This module provides a set of Sass functions for working with Sass::Script::Value::Number
#
module Archetype::SassExtensions::Numbers

  RESOLUTIONS = {
    'dpi'  => 96.0,         # dots per inch
    'dpcm' => 2.54 * 96.0,  # dots per centimeter
    'dppx' => 1.0           # dots per pixel
  }

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

  #
  # converts a decimal number into a fraction
  #  credit goes to Christopher Lord (https://github.com/clord/fraction)
  #
  # *Parameters*:
  # - <tt>$number</tt> {Number} the number to convert
  # *Returns*:
  # - {String} the number represented as a fraction
  #
  def to_fraction(number)
    assert_type number, :Number
    numerator = m22 = 1
    m12 = denominator = 0
    x = number.value
    while denominator * (ai = x.to_i) + m22 <= 10
      m12, numerator = [numerator, (numerator * ai + m12).to_i]
      m22, denominator = [denominator, (denominator * ai + m22).to_i]
      break if (x == ai) || (x - ai).abs < 0.000000000001
      x = 1.0 / (x - ai)
    end
    return Sass::Script::Value::String.new(numerator.to_s + '/' + denominator.to_s)
  end

  def _convert_resolution(number, type)
    assert_type number, :Number
    # nothing to do if we're already in the correct format
    return number if (number.unit_str.to_s == type)
    # otherwise, normalize to ratio, then convert
    number = resolution_to_ratio(number).value
    return Sass::Script::Value::Number.new(number * RESOLUTIONS[type], [type])
  end

  #
  # converts any valid resolution value into a ratio
  #
  # *Parameters*:
  # - <tt>$number</tt> {Number} the resolution to convert
  # *Returns*:
  # - {Number} the resolution as a ratio
  #
  def resolution_to_ratio(number)
    assert_type number, :Number
    # just return if we've already got a unitless number
    return number if number.unitless?
    unit = number.unit_str.to_s
    # if we don't understand the unit...
    if RESOLUTIONS[unit].nil?
      # warn
      helpers.logger.record(:warning, "don't know how to convert `#{number}`")
      # and return zero
      return Sass::Script::Value::Number.new(0)
    end
    return Sass::Script::Value::Number.new(number.value.to_f / RESOLUTIONS[unit])
  end

  #
  # converts any valid resolution value into dppx (dots per pixel)
  #
  # *Parameters*:
  # - <tt>$number</tt> {Number} the resolution to convert
  # *Returns*:
  # - {Number} the resolution as dppx
  #
  def resolution_to_dppx(number)
    return _convert_resolution(number, 'dppx')
  end

  #
  # converts any valid resolution value into dpi (dots per inch)
  #
  # *Parameters*:
  # - <tt>$number</tt> {Number} the resolution to convert
  # *Returns*:
  # - {Number} the resolution as dpi
  #
  def resolution_to_dpi(number)
    return _convert_resolution(number, 'dpi')
  end

  #
  # converts any valid resolution value into dpcm (dots per centimeters)
  #
  # *Parameters*:
  # - <tt>$number</tt> {Number} the resolution to convert
  # *Returns*:
  # - {Number} the resolution as dpcm
  #
  def resolution_to_dpcm(number)
    return _convert_resolution(number, 'dpcm')
  end
end
