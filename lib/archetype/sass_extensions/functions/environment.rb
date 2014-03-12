#
# Archetype environment
#
module Archetype::SassExtensions::Environment
  #
  # get the current environment (this is similar to compass_env)
  #
  # *Returns*:
  # - {String} the current environment the compiler is running in
  #
  def archetype_env
    return identifier((Compass.configuration.environment || :development).to_s)
  end

  #
  # namespaces a string
  #
  # *Parameters*:
  # - <tt>$string</tt> {String} the string to namespace
  # *Returns*:
  # - {String} the namespaced string
  #
  def archetype_namespace(string)
    namespace = environment.var('CONFIG_NAMESPACE')
    return string if is_null(namespace).value
    return identifier(namespace.value + '_' + string.value)
  end

  #
  # gets the value of the given key from the `meta` config map
  #
  # *Parameters*:
  # - <tt>$key</tt> {String} the key to lookup
  # *Returns*:
  # - {*} the value from the meta map
  #
  def archetype_meta(key)
    # if `$CONFIG_META` is set, use it, otherwise, use the one set on the configuration object
    meta = environment.var('CONFIG_META') || Compass.configuration.meta || {}
    # convert it to a hash
    meta = helpers.map_to_hash(meta)
    # fetch the value for the key
    value = meta[key.value]
    # if we got nothing...
    if value.nil?
      # return `null`
      return null
    # if it's a Sass::Script value...
    elsif value.is_a?(Sass::Script::Value::Base)
      # just return it
      return value
    # otherwise...
    else
      # convert it to a Sass::Script::String
      return identifier(helpers.to_str(value))
    end
  end
end
