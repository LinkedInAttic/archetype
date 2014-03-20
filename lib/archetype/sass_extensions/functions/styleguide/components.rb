module Archetype::SassExtensions::Styleguide

  private

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
  def component_exists(id, theme = nil, extension = nil, force = false)
    status = false
    theme = get_theme(theme) if not theme.is_a? Hash
    id = helpers.to_str(id)
    # determine the status of the component
    status = (extension.nil?) ? (not theme[:components][id].nil?) : theme[:extensions].include?(extension)
    return (status and not force and Compass.configuration.memoize)
  end

end
