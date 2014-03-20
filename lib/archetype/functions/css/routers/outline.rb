module Archetype::Functions::CSS

  private

  #
  # router for `outline` properties
  #
  def self.get_derived_styles_router_for_outline(related, property)
    properties = %w(color style width)
    styles, reconstruct = with_each_available_relative_if_root(related, property) do |items, comma_separated|
      # blow away anything we've already discovered (because it's irrelevant)
      styles = ::Archetype::Hash.new
      items.reject! do |item|
        if item.is_a?(Sass::Script::Value::Color)
          styles[:color] = item
        elsif item.is_a?(Sass::Script::Value::Number)
          styles[:width] = item
        else
          case helpers.to_str(item)
          when 'invert'
            styles[:color] = item
          when /^(?:none|hidden|dotted|dashed|solid|double|groove|ridge|inset|outset)$/
            styles[:style] = item
          when /^(?:thin|medium|thick)$/
            styles[:width] = item
          when 'inherit'
            next
          end
        end
        true
      end
      # at this point, we should only have `inherit` values left
      items.each do |item|
        if styles[:color].nil?
          styles[:color] = item
        elsif styles[:style].nil?
          styles[:style] = item
        else
          styles[:width] ||= item
        end
      end
      styles = set_default_styles(styles, 'outline', properties)
      # make the styles available to the calling context
      styles
    end

    if reconstruct
      return nil if styles.nil? or styles.empty?
      styles = set_default_styles(styles, 'outline', properties)
      return Sass::Script::Value::List.new([styles[:color], styles[:style], styles[:width]], :space)
    end

    # otherwise just return the value we were asked for
    return styles
  end
end