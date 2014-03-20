module Archetype::Functions::CSS

  private

  #
  # router for `transition` properties
  #
  def self.get_derived_styles_router_for_transition(related, property)
    properties = %w(property duration timing-function delay)
    styles, reconstruct = with_each_available_relative_if_root(related, property) do |items, comma_separated|
      # blow away anything we've already discovered (because it's irrelevant)
      timings = get_timing_values(items)
      items = items - timings
      # property duration timing-function delay
      styles = ::Archetype::Hash.new
      styles[:duration] = timings.shift
      styles[:delay]    = timings.shift

      items.reject! do |item|
        case helpers.to_str(item)
        when R_TIMING_FUNCTION
          styles[:timing_function] = item
        else
          next
        end
        true
      end

      # set defaults if we missed anything...
      styles[:property] = items.shift
      styles = set_default_styles(styles, 'transition', properties)
      # make the styles available to the calling context
      styles
    end

    if reconstruct
      if styles.nil? or styles[:property].nil?
        return warn_not_enough_infomation_to_derive(property) if not styles.empty?
        return nil
      end
      value = extrapolate_shorthand_simple(styles, property, properties)
      return Sass::Script::Value::List.new(value, :space)
    end

    # otherwise just return the value we were asked for
    return styles
  end
end