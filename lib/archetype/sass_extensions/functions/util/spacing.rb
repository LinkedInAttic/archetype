module Archetype::SassExtensions::Util::Spacing

  #
  # abstract factor of measurement
  #
  # *Parameters*:
  # - <tt>$number</tt> {Number} unit of measurement
  # - <tt>$abuse</tt> {Boolean} if `false`, $number cannot be a fraction
  # - <tt>$direction</tt> {Boolean} [horizontal|vertical] spacing
  # *Returns*:
  # - {Number} normalized number of measurement
  #
  def _archetype_integerize(number, abuse = bool(false))
    unless unitless(number)
      helpers.warn("[#{Archetype.name}:units] #{number} is not unitless, stripping units")
      number = strip_units(number)
    end
    config = (environment.var('CONFIG_UNIT_FORCE_INT') || bool(false)).value
    if config == 'strict' or !abuse.value
      return ceil(number)
    end
    return number
  end
  Sass::Script::Functions.declare :_archetype_integerize, [:number]
  Sass::Script::Functions.declare :_archetype_integerize, [:number, :abuse]

  #
  # abstract spacing calculations
  #
  # *Parameters*:
  # - <tt>$unit</tt> {Number} unit of measurement
  # - <tt>$direction</tt> {String} [horizontal|vertical] spacing
  # - <tt>$abuse</tt> {Boolean} @see _archetype_integerize
  # *Returns*:
  # - {Number} the calculated spacing
  #
  def _spacing(unit = null, direction = identifier(horizontal), abuse = bool(false))
    return null if helpers.is_null(unit)

    return unit unless (unit.is_a?(Sass::Script::Value::Number) && unitless(unit).to_bool)

    unit = _archetype_integerize(unit, abuse)
    direction = helpers.to_str(direction) == 'vertical' ? 'VERTICAL' : 'HORIZONTAL'
    config = "CONFIG_#{direction}_SPACING"
    spacing = environment.var(config)
    if spacing.nil?
      spacing = number(1, 'px')
      helpers.warn("[#{Archetype.name}:spacing] `#{config}` has not been set")
    end
    return unit.times(spacing)
  end
  Sass::Script::Functions.declare :_spacing, [:unit]
  Sass::Script::Functions.declare :_spacing, [:unit, :direction]
  Sass::Script::Functions.declare :_spacing, [:unit, :abuse]
  Sass::Script::Functions.declare :_spacing, [:unit, :direction, :abuse]

  #
  # horizontal spacing calculations
  #
  # *Parameters*:
  # - <tt>$unit</tt> {Number} unit of measurement
  # - <tt>$abuse</tt> {Boolean} @see _archetype_integerize
  # *Returns*:
  # - {Number} the calculated horizontal spacing
  #
  def horizontal_spacing(unit, abuse = bool(false))
    return _spacing(unit, null, abuse)
  end
  Sass::Script::Functions.declare :horizontal_spacing, [:unit]
  Sass::Script::Functions.declare :horizontal_spacing, [:unit, :abuse]

  #
  # vertical spacing calculations
  #
  # *Parameters*:
  # - <tt>$unit</tt> {Number} unit of measurement
  # - <tt>$abuse</tt> {Boolean} @see _archetype_integerize
  # *Returns*:
  # - {Number} the calculated vertical spacing
  #
  def vertical_spacing(unit, abuse = bool(false))
    return _spacing(unit, 'vertical', abuse)
  end
  Sass::Script::Functions.declare :vertical_spacing, [:unit]
  Sass::Script::Functions.declare :vertical_spacing, [:unit, :abuse]
end
