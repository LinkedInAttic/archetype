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

  #
  # converts any valid resolution value into a given resolution
  #
  # *Parameters*:
  # - <tt>$number</tt> {Number} the resolution to convert from
  # - <tt>$unit</tt> {String} the destination unit to convert to
  # *Returns*:
  # - {Number} the resolution in the destination unit
  #
  def resolution_to_x(number, unit = 'ratio')
    assert_type number, :Number
    ratio = 'ratio'

    to = (unit.respond_to?(:value) ? unit.value : unit).to_s
    from = number.unit_str.to_s
    unitless = number.unitless?

    # nothing to do if we're already in the correct format
    return number if ((from == to) || (unitless && to == ratio))

    # if we don't understand the unit...
    if RESOLUTIONS[from].nil? and not unitless
      # warn
      helpers.logger.record(:warning, "don't know how to convert `#{number}` to a #{to}")
      # and return zero
      return Sass::Script::Value::Number.new(0)
    end

    # convert it to a unitless ratio
    number = number.value.to_f / (RESOLUTIONS[from] || 1.0)
    # return early if we're looking for a ratio
    return Sass::Script::Value::Number.new(number) if to == ratio
    # otherwise convert to desination unit
    return Sass::Script::Value::Number.new(number * RESOLUTIONS[to], [to])
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
    return resolution_to_x(number, 'ratio')
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
    return resolution_to_x(number, 'dppx')
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
    return resolution_to_x(number, 'dpi')
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
    return resolution_to_x(number, 'dpcm')
  end
end
