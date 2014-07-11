module Archetype::SassExtensions::Styleguide
  #
  # interface for adding new components to the styleguide structure
  #
  # *Parameters*:
  # - <tt>$id</tt> {String} the component identifier
  # - <tt>$data</tt> {Map|List} the component data object
  # - <tt>$default</tt> {Map|List} the default data object (for extending)
  # - <tt>$theme</tt> {String} the theme to insert the component into
  # - <tt>$force</tt> {Boolean} if true, forcibly insert the component
  # *Returns*:
  # - {Boolean} whether or not the component was added
  #
  def styleguide_add_component(id, data, default = nil, theme = nil, force = false)
    _styleguide_debug "attempting to register component for `#{id}`", :add
    _styleguide_mutex_helper(id, theme) do |id, theme|
      components = theme[:components]
      # if force was true, we have to invalidate the memoizer
      memoizer.clear(theme[:name]) if force
      # if we already have the component, don't create it again
      if component_exists?(id, theme, nil, force) || component_is_frozen?(id, theme)
        _styleguide_debug "skipping component registration for `#{id}`. the component is already registered or frozen", :add
        return bool(false)
      end
      # otherwise add it
      components[id] = helpers.data_to_hash(default, 1, SPECIAL, ADDITIVES).merge(helpers.data_to_hash(data, 1, SPECIAL, ADDITIVES))
      _styleguide_debug "successfully registered component `#{id}`", :add
      _styleguide_debug components[id], :add
      return bool(true)
    end
  end
  Sass::Script::Functions.declare :styleguide_add_component, [:id, :data]
  Sass::Script::Functions.declare :styleguide_add_component, [:id, :data, :default]
  Sass::Script::Functions.declare :styleguide_add_component, [:id, :data, :default, :theme]

  #
  # interface for extending an existing components in the styleguide structure
  #
  # *Parameters*:
  # - <tt>$id</tt> {String} the component identifier
  # - <tt>$data</tt> {List} the component data object
  # - <tt>$theme</tt> {String} the theme to insert the component into
  # - <tt>$extension</tt> {String} the name of the extension
  # - <tt>$force</tt> {Boolean} if true, forcibly extend the component
  # *Returns*:
  # - {Boolean} whether or not the component was extended
  #
  def styleguide_extend_component(id, data, theme = nil, extension = nil, force = false)
    _styleguide_debug "attempting to extend component for `#{id}`", :extend
    _styleguide_debug "extension name is `#{extension.to_sass}`", :extend unless extension.nil?
    _styleguide_mutex_helper(id, theme) do |id, theme|
      components = theme[:components]
      # if force was set, we'll create a random token for the name
      if force
        extension = random_uid('extension')
        _styleguide_debug "forcibly extending...", :extend
      end
      # use the extension name or a snapshot of the extension
      extension = helpers.to_str(extension || data.to_sass)
      extensions = theme[:extensions]
      if component_exists?(id, theme, extension, force) || component_is_frozen?(id, theme)
        _styleguide_debug "skipping component extension for `#{id}`. the extension is already registered or frozen", :extend
        return bool(false)
      end
      extensions.push(extension)
      components[id] = (components[id] ||= Archetype::Hash.new).rmerge(helpers.data_to_hash(data, 1, SPECIAL, ADDITIVES))
      _styleguide_debug "successfully extended component `#{id}`", :extend
      _styleguide_debug components[id], :extend
      return bool(true)
    end
  end
  Sass::Script::Functions.declare :styleguide_extend_component, [:id, :data]
  Sass::Script::Functions.declare :styleguide_extend_component, [:id, :data, :theme]
  Sass::Script::Functions.declare :styleguide_extend_component, [:id, :data, :extension]
  Sass::Script::Functions.declare :styleguide_extend_component, [:id, :data, :theme, :extension]

  #
  # check whether or not a component (or a component extension) has already been defined
  #
  # *Parameters*:
  # - <tt>$id</tt> {String} the component identifier
  # - <tt>$data</tt> {List} the component data object
  # - <tt>$theme</tt> {String} the theme to insert the component into
  # - <tt>$extension</tt> {String} the name of the extension
  # - <tt>$force</tt> {Boolean} if true, forcibly extend the component
  # *Returns*:
  # - {Boolean} whether or not the component/extension exists
  #
  def styleguide_component_exists(id, theme = nil, extension = nil, force = false)
    _styleguide_mutex_helper do
      extension = helpers.to_str(extension) if not extension.nil?
      return bool( component_exists?(id, theme, extension, force) )
    end
  end
  Sass::Script::Functions.declare :styleguide_component_exists, [:id]
  Sass::Script::Functions.declare :styleguide_component_exists, [:id, :theme]
  Sass::Script::Functions.declare :styleguide_component_exists, [:id, :theme, :extension]
  Sass::Script::Functions.declare :styleguide_component_exists, [:id, :theme, :extension, :force]

  #
  # removes a component definition
  #
  # *Parameters*
  # - <tt>$id</tt> {String} the component identifier
  # - <tt>$theme</tt> {String} the theme to insert the component into
  #
  def styleguide_remove_component(id, theme = nil)
    _styleguide_debug "removing component `#{id}`", :remove
    _styleguide_mutex_helper(id, theme) do |id, theme|
      theme[:components].delete(id)
      theme[:extensions].push(random_uid('remove'))
      return bool(true)
    end
  end
  Sass::Script::Functions.declare :styleguide_remove_component, [:id]
  Sass::Script::Functions.declare :styleguide_remove_component, [:id, :theme]

  #
  # flags a component definition as "frozen" (locked)
  #
  # *Parameters*
  # - <tt>$id</tt> {String} the component identifier
  # - <tt>$theme</tt> {String} the theme to insert the component into
  #
  def styleguide_freeze_component(id, theme = nil)
    _styleguide_debug "freezing component `#{id}`", :freeze
    _styleguide_mutex_helper(id, theme) do |id, theme|
      theme[:frozen] << id
      return bool(true)
    end
  end
  Sass::Script::Functions.declare :styleguide_freeze_component, [:id]
  Sass::Script::Functions.declare :styleguide_freeze_component, [:id, :theme]

  #
  # freezes all registered components
  #
  # *Parameters*
  # - <tt>$theme</tt> {String} the theme to insert the component into
  #
  def styleguide_freeze_all_components(theme = nil)
    _styleguide_debug "freezing ALL components", :freeze
    _styleguide_mutex_helper do
      theme = get_theme(theme)
      theme[:frozen] = Set.new(theme[:components].keys)
      return bool(true)
    end
  end
  Sass::Script::Functions.declare :styleguide_freeze_all_components, [:theme]

  #
  # "thaws" (unlocks) a frozen component
  #
  # *Parameters*
  # - <tt>$id</tt> {String} the component identifier
  # - <tt>$theme</tt> {String} the theme to insert the component into
  #
  def styleguide_thaw_component(id, theme = nil)
    _styleguide_debug "thawing component `#{id}`", :freeze
    _styleguide_mutex_helper(id, theme) do |id, theme|
      theme[:frozen].delete(id)
      return bool(true)
    end
  end
  Sass::Script::Functions.declare :styleguide_thaw_component, [:id]
  Sass::Script::Functions.declare :styleguide_thaw_component, [:id, :theme]

  #
  # freezes all registered components
  #
  # *Parameters*
  # - <tt>$theme</tt> {String} the theme to insert the component into
  #
  def styleguide_thaw_all_components(theme = nil)
    _styleguide_debug "thawing ALL components", :freeze
    _styleguide_mutex_helper do
      theme = get_theme(theme)
      theme[:frozen].clear
      return bool(true)
    end
  end
  Sass::Script::Functions.declare :styleguide_thaw_all_components, [:theme]

  #
  # gets a list of all known components
  #
  # *Parameters*:
  # - <tt>$theme</tt> {String} the theme to look within
  # *Returns*:
  # - {List} list of component identifiers
  #
  def styleguide_components(theme = nil)
    theme = get_theme(theme)
    keys = theme[:components].keys.map { |k| identifier(k) }
    return list(keys, :comma)
  end

  #
  # gets a list of all the current variants of a given component
  #
  # *Parameters*:
  # - <tt>$id</tt> {String} the component identifier
  # - <tt>$theme</tt> {String} the theme to look within
  # *Returns*:
  # - {List} list of component variants
  #
  def styleguide_component_variants(id, theme = nil)
    id = helpers.to_str(id)
    theme = get_theme(theme)
    component = theme[:components][id]
    return null if component.nil?
    variants = component.keys
    variants = variants.map { |k| identifier(k) }
    return list(variants, :comma)
  end

  private

  #
  # TODO - doc
  #
  def random_uid(str = '')
    return rand(36**8).to_s(36) + str
  end

  def component_is_frozen?(id, theme, warn = true)
    if theme[:frozen].include?(id)
      helpers.warn "[#{Archetype.name}:styleguide:frozen] the component `#{id}` has been frozen and cannot be modified" if warn
      return true
    end
    return false
  end

  #
  # check whether or not a component (or a component extension) has already been defined
  #
  # *Parameters*:
  # - <tt>id</tt> {String} the component identifier
  # - <tt>theme</tt> {String} the theme to insert the component into
  # - <tt>extension</tt> {String} the name of the extension
  # - <tt>force</tt> {Boolean} if true, forcibly extend the component
  # *Returns*:
  # - {Boolean} whether or not the component/extension exists
  #
  def component_exists?(id, theme = nil, extension = nil, force = false)
    status = false
    theme = get_theme(theme) if not theme.is_a? Hash
    id = helpers.to_str(id)
    # determine the status of the component
    status = (extension.nil?) ? (not theme[:components][id].nil?) : theme[:extensions].include?(extension)
    return (status and not force and Compass.configuration.memoize)
  end

end
