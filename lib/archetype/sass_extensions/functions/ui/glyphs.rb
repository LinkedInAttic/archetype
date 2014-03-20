module Archetype::SassExtensions::UI::Glyphs

  #
  # given a set of grid sizes and an individual size, return the closest matching size
  #
  # *Parameters*:
  # - <tt>$grids</tt> {List} the list of grid options
  # - <tt>$size</tt> {Number} the size to find a match for
  # *Returns*:
  # - {Number} the closest matching grid size
  #
  def choose_best_glyph_grid(grids, size)
    return grids if grids == null

    grids = grids.to_a

    # perfect match?
    if grids.include?(size)
      return size
    end

    # otherwise let's find the best match
    # start with assuming the first item is the best
    best = {
      :grid     => grids.first,
      :distance => (+1.0/0.0) # similuate Float::INFINITY, but for Ruby 1.8
    }

    # for each grid option...
    grids.each do |grid|
      # if the units are comparable...
      if unit(grid) == unit(size)

        tmp_grid = strip_units(grid).value.to_f
        tmp_size = strip_units(size).value.to_f

        # simple algorithm to compute the distance between the size and grid
        #  choose the lesser of the (mod) or (grid - mod)
        #  then divide it by grid^(number_of_grid_choices)
        mod = (tmp_size % tmp_grid)
        distance = [mod, tmp_grid - mod].min / tmp_grid**(grids.length)

        # if it's closer (smaller distance), use it...
        if distance < best[:distance]
          best = {
            :grid     => grid,
            :distance => distance
          }
        end
      end
    end
    # return the best match we found
    return best[:grid]
  end
  Sass::Script::Functions.declare :choose_best_glyph_grid, [:grids, :size]

  #
  # checks if a string looks like it's just a composition of character codes
  #
  # *Parameters*:
  # - <tt>$string</tt> {String} the string to check
  # *Returns*:
  # - {Boolean} whether or not the string looks like a sequence of character codes
  #
  def looks_like_character_code(string)
    string = helpers.to_str(string, ' ', :quotes)
    return bool(string =~ /^(\\([\da-fA-F]{4})\s*)+$/)
  end
  Sass::Script::Functions.declare :looks_like_character_code, [:string]


  #
  # registers a glyph library under a given key
  #
  def register_glyph_library(key, library)
    registry = archetype_glyphs_registry
    # if it's already in the registry, just return the current list
    if is_null(registry[key])
      registry = registry.dup
      registry[key] = library
      registry = Sass::Script::Value::Map.new(registry)
      environment.global_env.set_var('CONFIG_GLYPHS_LIBRARIES', registry)
    end
    return key
  end

  #
  # gets a glyph library as registered under the given key
  #
  def get_glyph_library(key)
    default_key = identifier('default')
    default = archetype_glyphs_registry[default_key] || null
    return default if key == default_key

    library = archetype_glyphs_registry[key]
    # if the library doesn't exist...
    if helpers.is_null(library)
      # notify the user
      helpers.warn("[archetype:glyph] could not find a glyph library for `#{library}`, using default")
      # and return the default
      return default
    end
    # merge the library with the default
    return map_merge(default, library)
  end


  def get_all_glyph_libraries
    return environment.var('CONFIG_GLYPHS_LIBRARIES') || Sass::Script::Value::Map.new
  end

  private

  def archetype_glyphs_registry
    registry = environment.var('CONFIG_GLYPHS_LIBRARIES')
    return registry.respond_to?(:to_h) ? registry.to_h : {}
  end
end
