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
end
