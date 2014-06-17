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
    _styleguide_mutex_helper(id, theme) do |id, theme|
      components = theme[:components]
      # if force was true, we have to invalidate the memoizer
      memoizer.clear(theme[:name]) if force
      # if we already have the component, don't create it again
      return bool(false) if component_exists?(id, theme, nil, force) || component_is_frozen?(id, theme)
      # otherwise add it
      components[id] = helpers.data_to_hash(default, 1, SPECIAL, ADDITIVES).merge(helpers.data_to_hash(data, 1, SPECIAL, ADDITIVES))
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
    _styleguide_mutex_helper(id, theme) do |id, theme|
      components = theme[:components]
      # if force was set, we'll create a random token for the name
      extension = random_uid('extension') if force
      # use the extension name or a snapshot of the extension
      extension = helpers.to_str(extension || data.to_sass)
      extensions = theme[:extensions]
      return bool(false) if component_exists?(id, theme, extension, force) || component_is_frozen?(id, theme)
      extensions.push(extension)
      components[id] = (components[id] ||= Archetype::Hash.new).rmerge(helpers.data_to_hash(data, 1, SPECIAL, ADDITIVES))
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
    _styleguide_mutex_helper do
      theme = get_theme(theme)
      theme[:frozen].clear
      return bool(true)
    end
  end
  Sass::Script::Functions.declare :styleguide_thaw_all_components, [:theme]

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
