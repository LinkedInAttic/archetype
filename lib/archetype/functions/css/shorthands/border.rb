module Archetype::Functions::CSS

  private

  #
  # deconstructs `border` shorthand properties into it's longhand values
  #
  def self.deconstruct_shorthand_for_border(items, types)
    tmp = ::Archetype::Hash.new
    items.reject! do |item|
      if item.is_a?(Sass::Script::Value::Number)
        tmp[:width] = item
      elsif item.is_a?(Sass::Script::Value::Color)
        tmp[:color] = item
      else
        case helpers.to_str(item)
        when /^(?:thin|medium|thick)$/
          tmp[:width] = item
        when /^(?:none|hidden|dotted|dashed|solid|double|groove|ridge|inset|outset)$/
          tmp[:style] = item
        else
          next
        end
      end
      true
    end
    items.each do |item|
      if helpers.to_str(item) == 'inherit'
        if tmp[:width].nil?
          tmp[:width] = item
        elsif tmp[:style].nil?
          tmp[:style] = item
        else
          tmp[:color] ||= item
        end
      end
    end
    return set_default_styles(tmp, 'border', types)
  end

  #
  # deconstructs `border-image` shorthand property into it's longhand values
  #
  def self.deconstruct_shorthand_for_border_image(items, properties)
    contexts = [:image_slice, :image_width, :image_outset]
    context = contexts.shift
    count = 1
    styles = ::Archetype::Hash.new
    items.each do |item|
      # source slice width outset repeat
      # <source> <slice {1,4}> / <width {1,4}> <outset> <repeat{1,2}>
      case helpers.to_str(item)
      when /^(?:url\(.*\)|none)$/
        styles[:image_source] = item
      when /^(?:stretch|repeat|round|space)$/
        styles[:image_repeat] ||= []
        styles[:image_repeat] << item
      when /(.+)\/(.+)/ # delimiter to denote which context (slice, width, outset) we're observing
        [$1, $2].each_with_index do |item, i|
          count -= 1 if item == 'fill' # don't count `fill`
          if count > 4 or i == 1
            context = contexts.shift
            count = 1
          end
          if context
            item = (item =~ /^(\d+(?:\.\d+)?)(.*)/) ? Sass::Script::Value::Number.new($1.to_f, [$2]) : Sass::Script::Value::String.new(item)
            styles[context] ||= []
            styles[context] << item
            count += 1
          end
        end
      when /^\d+/
        # if we've reached out limit for the current context, adjust
        if count > 4
          context = contexts.shift
          count = 1
        end
        # if we have a context, stash the value onto it
        if context
          styles[context] ||= []
          styles[context] << item
          count += 1
        end
      when /^fill$/
        styles[:image_slice] ||= []
        styles[:image_slice] << item
         # don't count `fill`
      when /^auto$/
        styles[:image_width] ||= []
        styles[:image_width] << item
        count += 1
      when '/'
        context = contexts.shift
        count = 1
      else
        next
      end
      true
    end
    styles = set_default_styles(styles, 'border-image', properties)
  end
end