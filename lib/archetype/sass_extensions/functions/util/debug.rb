module Archetype::SassExtensions::Util::Debug

  #
  # check if debug is enabled
  #
  # *Parameters*:
  # - <tt>$iff</tt> {Boolean} optional override for `$CONFIG_DEBUG`
  # *Returns*:
  # - {Boolean} whether or not debug is enabled
  #
  def is_debug_enabled(iff = nil)
    # debug is only available in DEBUG environments, so check that first
    return bool(false) unless (environment.var('CONFIG_DEBUG_ENVS') || []).to_a.include?(archetype_env)
    # then check if the debug flag/override is truthy
    # if the param is non-null, then use it
    return iff unless is_null(iff).value
    # otherwise, use `CONFIG_DEBUG`
    return environment.var('CONFIG_DEBUG') || bool(false)
  end
  Sass::Script::Functions.declare :is_debug_enabled, [:iff]

end
