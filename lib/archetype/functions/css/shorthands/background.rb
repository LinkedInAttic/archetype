module Archetype::Functions::CSS

  private

  #
  # deconstructs `background` shorthand property into it's longhand values
  #
  def self.deconstruct_shorthand_for_background(items, comma_separated, properties)
    i = 0
    # blow away anything we've already discovered (because it's irrelevant)
    styles = ::Archetype::Hash.new
    properties.each { |k| styles[k.to_sym] = [] }

    (comma_separated ? items.to_a : [items]).each do |items|
      items = items.to_a.dup if items.respond_to?(:to_a)
      items.reject! do |item|
        if item.is_a?(Sass::Script::Value::Color)
          styles[:color] << item
        else
          case helpers.to_str(item)
          when /^(?:(?:no-)?repeat(?:-[xy])?|inherit)$/
            styles[:repeat] << item
          # origin or clip
          when /^(?:border|padding|content)-box$/
            # if we already have an `origin`, then this is `clip`, otherwise it's `origin`
            styles[styles[:origin][iteration].nil? ? :origin : :clip] << item
          when /^(?:url\(.*\)|none)$/
            # record multiple images if needed
            styles[:image] << item
          when /^(?:scroll|fixed|local)$/
            styles[:attachment] << item
          when /^(?:cover|contain)$/
            styles[:size] << item
          when /^(?:top|right|bottom|left|center)$/
            styles[:position][i] ||= []
            styles[:position][i] << item
          else
            next
          end
        end
        true
      end

      # deal with the `position` and `size`, as they're order dependent...
      items.each do |item|
        if item.is_a?(Sass::Script::Value::Number) or helpers.to_str(item) == 'auto'
          styles[:position][i] ||= []
          if styles[:position][i].length < 2
            styles[:position][i] << item
          else
            styles[:size][i] ||= []
            styles[:size][i] = styles[:size][i].to_a
            styles[:size][i] << item
          end
        end
      end

      [:position, :size].each do |k|
        styles[k][i] = Sass::Script::List.new(styles[k][i], :space) if styles[k][i].is_a?(Array)
      end

      # ...
      properties.each { |k| styles[k.to_sym] << default("background-#{k}") if styles[k.to_sym][i].nil?}
      i += 1
    end
    return styles
  end
end