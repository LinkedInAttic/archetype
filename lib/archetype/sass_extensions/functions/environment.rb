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
    return Sass::Script::Value::String.new((Compass.configuration.environment || :development).to_s)
  end
end
