module Archetype::SassExtensions::Styleguide

  private

  def memoizer
    Archetype::Functions::StyleguideMemoizer
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
    return definition
  end

  def self.reset!(filename = nil)
    @@archetype_styleguide_mutex.synchronize do
      if filename.nil?
        @@styleguide_themes = {}
      else
        (@@styleguide_themes ||= {}).delete(filename.hash)
      end
    end
  end

end
