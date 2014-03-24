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
    meta = environment.var('CONFIG_META') || Compass.configuration.archetype_meta || {}
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

  #
  # registers an Archetype module as active
  #
  # *Parameters*:
  # - <tt>$name</tt> {String} the module name
  # *Returns*:
  # - {List} the list of current registered modules
  #
  def register_archetype_module(name)
    registry = archetype_modules_registry
    # if it's already in the registry, just return the current list
    return list(registry, :comma) if archetype_modules_registry.include?(name)
    # update the registry with the module name
    registry = list(registry.dup.push(name), :comma)
    environment.global_env.set_var('ARCHETYPE_MODULES_REGISTRY', registry)
    # return the registry
    return registry
  end

  #
  # checks to see if a required module is loaded or not
  #  if not, throws an error
  #
  # *Parameters*:
  # - <tt>$name</tt> {String} the module name
  # *Returns*:
  # - {Boolean} whether or not all the modules are registered
  #
  def require_archetype_modules(*names)
    return check_archetype_modules(names, true)
  end
  alias_method :require_archetype_module, :require_archetype_modules

  #
  # checks whether or not a module has been registered
  #
  # *Parameters*:
  # - <tt>$name</tt> {String} the module name
  # *Returns*:
  # - {Boolean} whether or not all the modules are registered
  #
  def has_archetype_modules(*names)
    return check_archetype_modules(names, false)
  end
  alias_method :has_archetype_module, :has_archetype_modules

  #
  # sets the intialization state of Archetype
  #
  # *Parameters*
  # - <tt>$state</tt> {*} the state to set
  # *Returns*:
  # - {*} the state that was just set
  #
  def init_archetype(state = identifier('done'))
    environment.global_env.set_var('ARCHETYPE_INIT', state)
    return state
  end

  #
  # sets the intialization state of Archetype to `skip`
  #
  # *Returns*:
  # - {String} the state `skip` that was just set
  #
  def skip_archetype_init
    init_archetype(identifier('skip'))
  end

  #
  # sets the intialization state of Archetype to `null`
  #
  # *Returns*:
  # - {Null} the state `null` that was just set
  #
  def force_archetype_init
    init_archetype(null)
  end

  #
  # gets Archetype's current initialization state
  #
  # *Returns*:
  # - {*} Archetype's current initialization state
  #
  def archetype_init_state
    return environment.var('ARCHETYPE_INIT') || null
  end

private

  def check_archetype_modules(names, warn = false)
    missing = []
    names.each do |name|
      missing << name unless archetype_modules_registry.include?(name)
    end
    if missing.count > 0 and warn
      helpers.logger.record(:error, "[archetype:module:missing] the required module#{missing.count > 1 ? 's are' : ' is'} missing: #{helpers.to_str(missing)}")
    end
    return bool(missing.count == 0)
  end

  def archetype_modules_registry
    (environment.var('ARCHETYPE_MODULES_REGISTRY') || []).to_a
  end

end
