# :stopdoc:

%w(constants helpers routers shorthands).each do |dep|
  require "archetype/functions/css/#{dep}"
end

module Archetype::Functions::CSS
  #include Sass::Script::Value::Helpers

  #
  # returns a best guess for the default CSS value of a given property
  #
  # *Parameters*:
  # - <tt>key</tt> {String} the property to lookup
  # *Returns*:
  # - {*} the default value
  #
  def self.default(key)
    value = ALL_CSS_PROPERTIES[key] || :invalid
    if value.is_a?(Array)
      value = Sass::Script::Value::List.new(value.map {|item| CSS_PRIMITIVES[item]}, :space)
    else
      value = CSS_PRIMITIVES[value]
    end
    helpers.warn("[#{Archetype.name}:css:default] cannot find a default value for `#{key}`") if value.nil?
    return value
  end

  #
  # calculates derived styles from a given map
  #
  # *Parameters*:
  # - <tt>map</tt> {Sass::Script::Value::Map} the map of styles
  # - <tt>properties</tt> {String|List|Array} the properties to extract the derived styles for
  # - <tt>format</tt> {String} the format to return the results in [auto|map|list]
  # - <tt>strict</tt> {Boolean} if true, will only return an exact match, and not try to extrapolate the value (TODO)
  # *Returns*:
  # - {*} the derived styles as either a list/map of the values or the individual value itself (based on the format)
  #
  def self.get_derived_styles(map, properties = [], format = :auto, strict = false)
    # TODO how to handle multiple values?
    computed = ::Archetype::Hash.new
    (properties || []).to_a.each do |property|
      value = Sass::Script::Value::Null.new
      if not property.value.nil?
        property = helpers.to_str(property, ' ', :quotes)
        # simple case, exact match only
        value = map[property] if map.key? property

        # if we're not doing strict matching...
        if not strict
          # if the property is a short- or long-hand, we need to figure out what the value actually is
          value = get_derived_styles_via_router(map, property) || value
        end
      end
      computed[property] = value
    end

    format = :map if computed.length > 1 and format == :auto

    case format
    when :map
      return helpers.hash_to_map(computed)
    when :list
      return Sass::Script::Value::List.new(computed.values, :comma)
    else
      return computed.values.first
    end
  end
end
