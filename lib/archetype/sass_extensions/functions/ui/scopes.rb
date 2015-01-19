module Archetype::SassExtensions::UI::Scopes

  #
  # registers a breakpoint
  #
  # *Parameters*:
  # - <tt>$key</tt> {String} the key to register it under
  # - <tt>$value</tt> {*} the value to register
  # - <tt>$force</tt> {Boolean} if true, forces any new value into the registry
  # *Returns*:
  # - {Boolean} whether or not the value was registered
  #
  def register_breakpoint(key, value, force = nil)
    # we need a dup as the Hash is frozen
    breakpoints = registered_breakpoints.dup
    force = force.nil? ? false : force.to_bool
    not_registered = breakpoints[key].nil? || helpers.is_null(breakpoints[key])
    # if there's no key registered...
    if force || not_registered
      # just register the value
      breakpoints[key] = value
    # otherwise, if the current value is different...
    elsif breakpoints[key] != value
      # throw a warning
      helpers.warn("[#{Archetype.name}:breakpoint:register] a breakpoint for `#{key}` is already set to `#{breakpoints[key]}`, ignoring `#{value}`")
      return bool(false)
    end
    environment.global_env.set_var('CONFIG_BREAKPOINTS', Sass::Script::Value::Map.new(breakpoints))
    return bool(true)
  end
  Sass::Script::Functions.declare :register_breakpoint, [:key, :value]
  Sass::Script::Functions.declare :register_breakpoint, [:key, :value, :force]

  #
  # retrieves a breakpoint
  #
  # *Parameters*:
  # - <tt>$key</tt> {String} the key to lookup
  # *Returns*:
  # - {*} the registered breakpoint
  #
  def get_breakpoint(key)
    if disabled_breakpoints.include?(key)
      helpers.debug("[#{Archetype.name}:breakpoint:get] a breakpoint for `#{key}` was found, but is currently disabled (most likely with `toggle-breakpoint` or `disable-breakpoint`).")
      return null
    end
    breakpoint = registered_breakpoints[key] || null
    if breakpoint.nil? || helpers.is_null(breakpoint)
      helpers.warn("[#{Archetype.name}:breakpoint:get] a breakpoint for `#{key}` was not found.")
    end
    return breakpoint
  end
  Sass::Script::Functions.declare :get_breakpoint, [:key]

  #
  # Enable a breakpoint.
  #
  # *Parameters*:
  # - <tt>$key</tt> {String} the key to enable.
  # *Returns*:
  # - {Boolean} true, if the key is enabled successfully
  #
  def enable_breakpoint(key)
    return toggle_breakpoint(key, true)
  end
  Sass::Script::Functions.declare :enable_breakpoint, [:key]

  #
  # Disable a breakpoint.
  #
  # *Parameters*:
  # - <tt>$key</tt> {String} the key to disable.
  # *Returns*:
  # - {Boolean} true, if the key disabled successfully
  #
  def disable_breakpoint(key)
    return toggle_breakpoint(key, false)
  end
  Sass::Script::Functions.declare :disable_breakpoint, [:key]

  #
  # convert a modifier/element context to a BEM style selector
  #
  # *Parameters*:
  # - <tt>$context</tt> {String} the root selector to scope to
  # - <tt>$element</tt> {String} the element name
  # - <tt>$modifier</tt> {String} the modifier
  # *Returns*:
  # - {String} the BEM formatted selector
  #
  def bem_selector(context = nil, element = nil, modifier = nil)
    element_separator = environment.var('CONFIG_BEM_ELEMENT_SEPARATOR')
    element_separator = element_separator.nil? ? '__' : element_separator.value

    modifier_separator = environment.var('CONFIG_BEM_MODIFIER_SEPARATOR')
    modifier_separator = modifier_separator.nil? ? '--' : modifier_separator.value

    context  = helpers.is_null(context) ? ''  : context.value
    element  = helpers.is_null(element) ? nil : element.value
    modifier = helpers.is_null(modifier) ? nil : modifier.value

    selector = context

    warning = "[#{Archetype.name}:bem] the current context may produce a non-standard BEM selector for";

    unless element.nil?
      helpers.warn("#{warning} element `#{element}`: #{context}") if (context.include?(element_separator) || context.include?(modifier_separator))
      selector = "#{selector}#{element_separator}#{element}"
    end

    unless modifier.nil?
      helpers.warn("#{warning} modifier `#{modifier}`: #{context}") if context.include?(modifier_separator)
      selector = "#{selector}#{modifier_separator}#{modifier}"
    end

    return identifier(selector)
  end
  Sass::Script::Functions.declare :bem_selector, [:context]
  Sass::Script::Functions.declare :bem_selector, [:context, :element]
  Sass::Script::Functions.declare :bem_selector, [:context, :modifier]
  Sass::Script::Functions.declare :bem_selector, [:context, :element, :modifier]

private

  def registered_breakpoints
    breakpoints = environment.var('CONFIG_BREAKPOINTS')
    breakpoints.respond_to?(:to_h) ? breakpoints.to_h : {}
  end

  def disabled_breakpoints
    breakpoints = environment.var('CONFIG_BREAKPOINTS_DISABLED')
    breakpoints.respond_to?(:to_a) ? breakpoints.to_a : {}
  end

  # Enable or disable a breakpoint.
  #
  # *Parameters*:
  # - <tt>$key</tt> {String} the key to enable or disable.
  # - <tt>$toggle</tt> {Boolean} Set to true to enable the breakpoint. false to disable it.
  # *Returns*:
  # - {Boolean} true, if the disable or enable operation was successful.
  #
  def toggle_breakpoint(key, toggle)
    friendly_method = toggle ? 'enable' : 'disable'
    if registered_breakpoints[key].nil? || helpers.is_null(registered_breakpoints[key])
      helpers.warn("[#{Archetype.name}:breakpoint:#{friendly_method}] a breakpoint for `#{key}` was not found.")
      return bool(false)
    end

    method = toggle ? 'delete' : 'add'

    # this will ensure that there aren't any duplicate keys
    breakpoints = Set.new(disabled_breakpoints)
    breakpoints.method(method).call(key)

    breakpoints = Sass::Script::Value::List.new(breakpoints, :space)
    environment.global_env.set_var('CONFIG_BREAKPOINTS_DISABLED', breakpoints)

    return bool(true)
  end

end
