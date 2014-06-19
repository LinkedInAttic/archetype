module Archetype::SassExtensions::Styleguide

  private

  def memoizer
    Archetype::Functions::StyleguideMemoizer
  end

  #
  # helper for operations that need to happen within a mutex
  #
  def _styleguide_mutex_helper(id = nil, theme = nil)
    (@@archetype_styleguide_mutex ||= Mutex.new).synchronize do
      if block_given?
        id.nil? ? yield : yield(helpers.to_str(id), get_theme(theme))
      end
    end
  end

  #
  # normalize the styleguide definition into a hash representative of the definition
  #
  # *Parameters*:
  # - <tt>definition</tt> {String|List|Hash|Map} the styleguide definition
  # *Returns*:
  # - {Hash} the normalized hash representing the styleguide definition
  #
  def normalize_styleguide_definition(definition)
    # if it's not a map, we got a description, which we need to convert
    definition = get_styles([definition], nil, nil) if not definition.is_a?(Sass::Script::Value::Map)
     # now convert the map to a hash if needed
    definition = helpers.data_to_hash(definition) if not definition.is_a?(Hash)
    definition = resolve_runtime_locale_values(definition)
    return definition
  end

  def self.reset!(filename = nil)
    debug = Compass.configuration.styleguide_debug
    (@@archetype_styleguide_mutex ||= Mutex.new).synchronize do
      if filename.nil?
        @@styleguide_themes = {}
      else
        (@@styleguide_themes ||= {}).delete(filename.hash)
      end
    end
  end

end
