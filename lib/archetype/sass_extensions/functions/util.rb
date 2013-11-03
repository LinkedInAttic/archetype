module Archetype::SassExtensions::Util
  #
  # simple test for `null` or `nil` value
  #
  def is_null(value)
    return Sass::Script::Bool.new(value.is_a?(Sass::Script::Value::Null) || value == Sass::Script::Value::String.new('nil'))
  end

end
