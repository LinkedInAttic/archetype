module Archetype::SassExtensions::Util


  #
  # simple test for `null` or `nil` value
  #
  def is_null(value)
    return Sass::Script::Bool.new(value.is_a?(Sass::Script::Value::Null) || value == Sass::Script::Value::String.new('nil'))
  end


  def multiple_values(*args)
    return helpers.array_to_meta(args)
  end

  # given a map with meta data, extract the message and substitute any key-value pairs (@see str-substitute)
  # @function  meta-message
  # @param     $map {Map} the map to observe
  # @param     $subsitutes {Map} the map of substitutes
  # @return    {String} the meta message
  def meta_message(map, subsitutes = nil)
    message = Sass::Script::Value::Null.new
    meta = map_get_meta(map)
    message = str_substitute(map_get(meta, Sass::Script::Value::String.new(helpers::META[:message])), subsitutes) if not meta.value.nil?
    return message
  end

  # check to see if a map key has multiple values
  # @function  map-key-has-multiple-values
  # @param     $map {Map} the map to observe
  # @return    {Boolean} whether or not the map key represents multiple values
  def map_key_has_multiple_values(map)
    meta = map_get_meta(map)
    return map_has_key(meta, Sass::Script::Value::String.new(helpers::META[:has_multiples])) if not meta.value.nil?
    return Sass::Script::Value::Bool.new(false);
  end

  # retrieve the archetype meta data from a map
  # @function  map-get-meta
  # @param     $map {Map} the map to observe
  # @return    {Map} the data contained within the meta key
  def map_get_meta(map)
    if map.is_a?(Sass::Script::Value::Map) and map_has_key(map, Sass::Script::Value::String.new(helpers::META[:meta])).value
      return map_get(map, Sass::Script::Value::String.new(helpers::META[:meta]))
    end
    return Sass::Script::Value::Null.new
  end

private
  def helpers
    @helpers ||= Archetype::Functions::Helpers
  end

end
