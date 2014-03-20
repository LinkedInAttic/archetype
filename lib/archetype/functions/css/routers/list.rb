module Archetype::Functions::CSS

  private

  #
  # router for `list-style` properties
  #
  def self.get_derived_styles_router_for_list(related, property)
    properties = %w(style-type style-position style-image)
    styles, reconstruct = with_each_available_relative_if_root(related, property) do |items, comma_separated|
      styles = ::Archetype::Hash.new
      if helpers.to_str(items) == 'inherit'
        styles[:style_image] = styles[:style_type] = styles[:style_position] = items
      else
        items.reject! do |item|
          case helpers.to_str(item)
          when /^(?:armenian|circle|cjk-ideographic|decimal(?:-leading-zero)?|disc|georgian|hebrew|(?:hiragana|katakana)(?:-iroha)?|(?:lower|upper)-(?:alpha|greek|latin|roman)|square)$/
            styles[:style_type] = item
          when /^(?:inside|outside)$/
            styles[:style_position] = item
          when /^url\(.*\)$/
            styles[:style_image] = item
          else
            next
          end
          true
        end

        items.each do |item|
          case helpers.to_str(item)
          when 'none'
            if styles[:style_type].nil?
              styles[:style_type] = item
            else
              styles[:style_image] ||= item
            end
          when 'inherit'
            if styles[:style_type].nil?
              styles[:style_type] = item
            elsif styles[:style_type].nil?
              styles[:style_position] = item
            else
              styles[:style_image] ||= item
            end
          end
        end
      end
      styles
    end

    if reconstruct
      return nil if styles.nil? or styles.empty?
      styles = set_default_styles(styles, 'list', properties)
      value = [styles[:style_type], styles[:style_position], styles[:style_image]]
      # we simplify it if the values are all identical
      return value.first if value.uniq.length == 1
      return Sass::Script::Value::List.new(value, :space)
    end

    # otherwise just return the value we were asked for
    return styles
  end
end