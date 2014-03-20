module Archetype::Functions::CSS

  private

  #
  # router for `background` properties
  #
  def self.get_derived_styles_router_for_background(related, property)
    properties = %w(color position size repeat origin clip attachment image)
    property_order = [:color, :position, :size, :repeat, :origin, :clip, :attachment, :image]

    styles, reconstruct = with_each_available_relative_if_root(related, property) do |items, comma_separated|
      deconstruct_shorthand_for_background(items, comma_separated, properties)
    end

    if reconstruct
      return warn_not_enough_infomation_to_derive(property) if styles.nil?

      shorthands = []
      total = 1
      styles.each do |key, value|
        total = value.length if value.is_a?(Array) && value.length > total
      end
      total.times do |i|
        shorthand = []
        properties.each { |k| shorthand << (styles[k.to_sym].is_a?(Array) ? styles[k.to_sym][i] : styles[k.to_sym]) || default("background-#{k}") }
        shorthands << Sass::Script::Value::List.new(shorthand, :space)
      end
      return Sass::Script::Value::List.new(shorthands, :comma)
    end

    # collapse any multi-background values we got
    styles = collapse_multi_value_lists(styles, :comma)

    # otherwise just return the value we were asked for
    return styles
  end
end