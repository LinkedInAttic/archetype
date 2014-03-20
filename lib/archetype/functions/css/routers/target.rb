module Archetype::Functions::CSS

  private

  #
  # router for `target` properties
  #
  def self.get_derived_styles_router_for_target(related, property)
    properties = %w(name new position)
    styles, reconstruct = with_each_available_relative_if_root(related, property) do |items, comma_separated|
      # blow away anything we've already discovered (because it's irrelevant)
      # target-name target-new target-position
      styles = ::Archetype::Hash.new
      styles[:name] = items.shift

      items.each do |item|
        case helpers.to_str(item)
        when /^(?:window|tab|none)$/
          styles[:new] = item
        when /^(?:above|behind|front|back)$/
          styles[:position] = item
        end
      end
      # set defaults if we missed anything...
      styles = set_default_styles(styles, 'target', properties)
      # make the styles available to the calling context
      styles
    end
    if reconstruct
      return warn_not_enough_infomation_to_derive(property) if styles.nil? or styles[:name].nil?
      value = extrapolate_shorthand_simple(styles, property, properties)
      return Sass::Script::Value::List.new(value, :space)
    end

    # otherwise just return the value we were asked for
    return styles
  end
end