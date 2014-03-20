module Archetype::Functions::CSS

  private

  #
  # router for `border` and `border-{position}`
  #
  def self.get_derived_styles_router_for_border_shorthands(property, types, related)
    styles = ::Archetype::Hash.new
    types.each do |type|
      value = get_derived_styles_router_for_border(related, "#{property}-#{type}")
      if value
        styles[type.to_sym] = value
        return warn_cannot_disambiguate_property(property) if value.to_a.to_a.length > 1
      end
    end
    return nil if styles.empty?
    return Sass::Script::Value::List.new(extrapolate_shorthand_simple(styles, property, types), :space)
  end

  #
  # router for `border` properties
  #
  def self.get_derived_styles_router_for_border(related, property)
    properties = {
      :image  => %w(image-source image-slice image-width image-outset image-repeat),
      :radius => %w(top-left-radius top-right-radius bottom-right-radius bottom-left-radius)
    }
    positions = %w(top right bottom left)
    types = %w(width style color)

    # shorthand for `border` and `border-{position}` will extrapolate from other shorthands
    return get_derived_styles_router_for_border_shorthands(property, types, related) if property =~ R_BORDER_SHORTHANDS

    case_type = case property
    when R_BORDER_IMG_OR_RADIUS
      $1.to_sym
    when R_BORDER_STD
      :border
    end

    properties = properties[case_type] || []
    styles = ::Archetype::Hash.new
    augmented = false

    with_each_available_relative(related, property) do |key, value|
      items = value.to_a.dup

      case case_type
      when :image
        # border-image
        styles[normalize_property_key(key)] = value
        augmented = !is_root_property?(key)
        if !augmented
          styles = deconstruct_shorthand_for_border_image(items, properties)
        end
      when :radius
        # border-radius
        pieces = key.split('-')
        if pieces.length > 2
          augmented = true
          if pieces.length > 3
            # one of the longhand properties
            # e.g. `border-top-right-radius`
            styles[normalize_property_key(key)] = value
          else
            # one of the not-so-short shorthands
            # e.g. `border-top-radius` (these aren't real properties, but Compass supports these, so why not)
            position = pieces[1]
            positions = [
              ['top', 'bottom'],
              ['left', 'right']
            ]
            vertical = positions[0].include?(position)
            positions[vertical ? 1 : 0].each do |alt_position|
              str = "border-#{vertical ? position : alt_position}-#{vertical ? alt_position : position}-radius"
              styles[normalize_property_key(str)] = value
            end
          end
        else
          augmented = false
          shorthand = items.to_a
          # TODO - doesn't support vertical radius correctly
          styles = ::Archetype::Hash.new
          styles[:top_left_radius]      = shorthand[0],
          styles[:top_right_radius]     = shorthand[1] || shorthand[0],
          styles[:bottom_right_radius]  = shorthand[2] || shorthand[0],
          styles[:bottom_left_radius]   = shorthand[3] || shorthand[1] || shorthand[0]
        end
      when :border
        key =~ R_BORDER_STD
        position, type = $1, $2
        if position or type
          augmented = true
          if position and type
            # one of the longhand properties
            # e.g. `border-top-style`
            styles[normalize_property_key(key)] = value
          else
            # one of the not-so-short shorthands
            # e.g. `border-top` or `border-style`
            if position
              # e.g. `border-top`
              tmp = deconstruct_shorthand_for_border(items, types)
              types.each { |k| styles[normalize_property_key("#{key}-#{k}")] = tmp[k.to_sym] }
            else
              # e.g. `border-style`
              pattern = /^border#{RS_BORDER_POSITION}#{type}$/
              tmp = extract_symmetical_values(items)
              ALL_CSS_PROPERTIES.each { |k, v| styles[normalize_property_key(k)] = tmp[$1.gsub('-', '').to_sym] if k =~ pattern }
            end
          end
        else
          tmp = deconstruct_shorthand_for_border(items, types)
          positions.each do |pos|
            types.each { |k| styles[normalize_property_key("border-#{pos}-#{k}")] = tmp[k.to_sym] }
          end
        end
      end
    end
    pattern = /^border#{RS_BORDER_TYPE}$/

    styles = collapse_multi_value_lists(styles)

    if (augmented and is_root_property?(property)) or property =~ pattern
      value = nil
      case case_type
      when :image
        slash = Sass::Script::Value::String.new('/')
        styles = set_default_styles(styles, 'border-image', properties)
        value = [styles[:image_source], styles[:image_slice], slash, styles[:image_width], slash, styles[:image_outset], styles[:image_repeat]]
      when :border
        # e.g. border-color
        type = $1
        tmp = ::Archetype::Hash.new
        positions.each do |pos|
          key = "border-#{pos}#{type}"
          tmp[pos.to_sym] = styles[normalize_property_key(key)] || default(key)
        end
        return nil if tmp.empty?
        return extrapolate_shorthand_symmetrical(tmp)
      else
        # radius
        value = extrapolate_shorthand_simple(styles, property, properties)
      end
      return value ? Sass::Script::Value::List.new(value, :space) : nil
    end

    return styles[normalize_property_key(property)]
  end
end