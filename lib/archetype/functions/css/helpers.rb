module Archetype::Functions::CSS

  private

  #
  # output a warning about a disambiguous property found that can't be fully derived
  #
  # *Parameters*:
  # - <tt>property</tt> {String} the property
  # - <tt>info</tt> {String} additional info to display
  #
  def self.warn_cannot_disambiguate_property(property, info = nil)
    info = (info.nil? or info.empty?) ? '' : " (#{info})"
    return warn("[#{Archetype.name}:css:derive] cannot disambiguate the CSS property `#{property}#{info}`")
  end

  #
  # output a warning if there isn't enough information to derive the value requested
  #
  # *Parameters*:
  # - <tt>property</tt> {String} the property
  # *Returns*:
  # - {Sass::Null}
  #
  def self.warn_not_enough_infomation_to_derive(property)
    return warn("[#{Archetype.name}:css:derive] there isn't enough information to derive `#{property}`, so returning `null`")
  end

  #
  # checks to see if a property is the root property or a descendent
  #
  # *Returns*:
  # - {Boolean} true if the property is a root property
  # *Returns*:
  # - {Sass::Null}
  #
  def self.is_root_property?(property)
    special_roots = %w(list-style border-image border-radius)
    return special_roots.push(get_property_base(property)).include?(property)
  end

  #
  # given a set of related properties, get the set of properties that are currently available
  #
  # *Parameters*:
  # - <tt>related</tt> {Hash} the hash of styles
  # - <tt>property</tt> {String} the property to observe
  # *Returns*:
  # - {Hash} the available related properties and their values
  #
  def self.filter_available_relatives(related, property)
    handler = "filter_available_relatives_for_#{get_property_base(property)}"
    # handle special cases like `border`
    if self.respond_to?(handler)
      set = self.method(handler).call(related, property)
    else
      set = Set.new
      previous = nil
      # find all potential parents (and self)
      property.split('-').each do |value|
        value = previous.nil? ? value : "#{previous}-#{value}"
        set << value
        previous = value
      end
      base = /(?:^|\s)#{Regexp.escape(property)}-[^\s]+(?:$|\s)/
      related.each do |key, value|
        set << key if key =~ base
      end
    end
    return related.select { |key, value| set.include?(key) }
  end

  #
  # filter relatives for `border`
  #
  def self.filter_available_relatives_for_border(related, property)
    set = Set.new
    set << property
    case property
    # border-radius and border-image
    when R_BORDER_IMG_OR_RADIUS
      match = $1
      if property == "border-#{match}" or match == 'radius'
        pattern = /^border-.*#{match}/
        ALL_CSS_PROPERTIES.each { |k,v| set << k if k =~ pattern }
      else
        set << "border-#{match}"
      end
    when R_BORDER_STD
      pattern = R_BORDER_STD
      if property != 'border'
        position, type = $1, $2
        if position
          if type
            # position and type
            # e.g. for border-top-width
            # we'll need: border, border-top, border-top-width, border-width
            pattern = /^(border|border#{position}(#{type})?$|border#{type})$/
          else
            # position only
            # e.g. for border-top
            # we'll need: border, border-top, border-top-{type}, border-{type}
            pattern = /^(border|border#{position}#{RS_BORDER_TYPE}?$|border#{RS_BORDER_TYPE})$/
          end
        else
          # type only
          # e.g. for border-width
          # we'll need: border, border-width, border-{position}-width, border-{position}
          pattern = /^(border|border#{RS_BORDER_POSITION}?#{type}$|border#{RS_BORDER_POSITION})$/
        end
      end
      ALL_CSS_PROPERTIES.each { |k,v| set << k if k =~ pattern }
    end
    return set
  end

  #
  # for each item in a given style object, if the value is an array, convert it to a Sass::List
  #
  # *Parameters*:
  # - <tt>styles</tt> {Hash} the styles
  # - <tt>separator</tt> {Symbol} the separator to use on the generated list
  # *Returns*:
  # - {Hash} the styles hash with updated values
  #
  def self.collapse_multi_value_lists(styles, separator = :space)
    styles.each do |key, value|
      if value.is_a?(Array)
        # if all the values are identical, we just need to return one
        styles[key] = value.uniq.length == 1 ? value.first : Sass::Script::Value::List.new(value, separator)
      end
    end
    return styles
  end

  #
  # normalizes the property into a key for use on a hash
  #
  # *Parameters*:
  # - <tt>property</tt> {String} the property to be used as a key
  # - <tt>base</tt> {String} the base of the property
  # *Returns*:
  # - {Symbol} the property normalized as a symbol
  #
  def self.normalize_property_key(property, base = nil)
    base ||= get_property_base(property)
    return property.gsub(/^#{Regexp.escape(base)}\-/, '').gsub('-', '_').to_sym
  end

  #
  # gets the base of a property
  #
  # *Parameters*:
  # - <tt>property</tt> {String} the property
  # *Returns*:
  # - {String} the base of the property
  #
  def self.get_property_base(property)
    return (property.match(/^([a-z]+)/) || [])[0]
  end

  #
  # extracts potential timing values from an array of values
  #
  # *Parameters*:
  # - <tt>value</tt> {Array} an array of Sass values
  # *Returns*:
  # - {Array} the extracted timing values
  #
  def self.get_timing_values(value)
    return value.select do |item|
      if item.is_a?(Sass::Script::Value::Number)
        unit = helpers.to_str(item.unit_str)
        ((item.unitless? and item.value == 0) or unit.include?('s'))
      end
    end
  end

  #
  # helper to iterate over each available relative property
  #
  # *Parameters*:
  # - <tt>related</tt> {Hash} the hash of styles
  # - <tt>property</tt> {String} the property to observe
  #
  def self.with_each_available_relative(related, property)
    filter_available_relatives(related, property).each do |key, value|
      yield(key, value) if block_given?
    end
  end

  #
  # helper to iterate over each available relative property, and executes a block if the property is a root property
  #
  # *Parameters*:
  # - <tt>related</tt> {Hash} the hash of styles
  # - <tt>property</tt> {String} the property to observe
  # *Returns*:
  # - {Hash} augmented styles hash
  #
  def self.with_each_available_relative_if_root(related, property)
    styles = ::Archetype::Hash.new
    augmented = false
    with_each_available_relative(related, property) do |key, value|
      styles[normalize_property_key(key)] = value
      augmented = !is_root_property?(key)
      # if it's the shorthand property...
      if !augmented
        styles = yield(value.to_a.dup, (value.is_a?(Sass::Script::Value::List) && value.separator == :comma)) if block_given?
      end
    end
    return styles, (augmented && is_root_property?(property))
  end

  #
  # given a styles object, sets default values for each property if not already set
  #
  # *Parameters*:
  # - <tt>styles</tt> {Hash} the styles
  # - <tt>base</tt> {String} the base string
  # - <tt>properties</tt> {Array} the properties to default if not set
  # *Returns*:
  # - {Hash} augmented styles hash
  #
  def self.set_default_styles(styles, base, properties)
    properties.each { |k| styles[normalize_property_key(k, base)] ||= default("#{base}-#{k}") }
    return styles
  end

  #
  # given a list of symmetrical values, extracts the [top right bottom left] key-value pairs
  #
  # *Parameters*:
  # - <tt>items</tt> {Array} the items
  # *Returns*:
  # - {Hash} the hash of [top right bottom left]
  #
  def self.extract_symmetical_values(items)
    return {
      :top        => items[0],
      :right      => items[1] || items[0],
      :bottom     => items[2] || items[0],
      :left       => items[3] || items[1] || items[0]
    }
  end

  #
  # wrapper to display a warning and return Sass::Null
  #
  # *Parameters*:
  # - <tt>msg</tt> {String} the message to display
  # *Returns*:
  # - {Sass::Null}
  #
  def self.warn(msg)
    helpers.warn msg
    return Sass::Script::Value::Null.new
  end

  # shortcut to Archetype::Functions::Helpers
  def self.helpers
    Archetype::Functions::Helpers
  end

end
