module Archetype::SassExtensions::Styleguide

  private

  #
  # keep a registry of styleguide themes
  #
  # *Parameters*:
  # - <tt>theme</tt> {String} the theme to use
  # *Returns*:
  # - {Hash} the theme
  #
  def get_theme(theme)
    if @@styleguide_themes.nil?
      # bind a callback to file save to cleanup the cache if needed
      Compass.configuration.on_stylesheet_saved do |filename|
        ::Archetype::SassExtensions::Styleguide.reset!(filename) unless Compass.configuration.memoize == :aggressive
      end
    end
    @@styleguide_themes ||= {}
    theme_name = helpers.to_str(theme || environment.var('CONFIG_THEME') || Archetype.name)
    key = nil
    begin
      key = environment.options[:css_filename].hash
    end
    # if we're aggressively memoizing, store everything across the session
    if Compass.configuration.memoize == :aggressive or not key
      styleguide_store = @@styleguide_themes
    #otherwise, just store it per this file instance
    else
      styleguide_store = @@styleguide_themes[key] ||= {}
    end
    theme = styleguide_store[theme_name] ||= {}
    theme[:name] ||= theme_name
    theme[:components] ||= {}
    theme[:extensions] ||= []
    return theme
  end

end
