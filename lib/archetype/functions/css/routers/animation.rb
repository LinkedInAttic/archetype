module Archetype::Functions::CSS

  private

  #
  # router for `animiation` properties
  #
  def self.get_derived_styles_router_for_animation(related, property)
    properties = %w(name duration timing-function delay iteration-count direction play-state)
    styles, reconstruct = with_each_available_relative_if_root(related, property) do |items, comma_separated|
      # blow away anything we've already discovered (because it's irrelevant)
      # identify the items that are timing units
      timings = get_timing_values(items)
      items = items - timings
      # name duration timing-function delay iteration-count direction
      styles = ::Archetype::Hash.new
      styles[:duration] = timings.shift
      styles[:delay]    = timings.shift
      items.reject! do |item|
        case helpers.to_str(item)
        when /^(?:normal|alternate|reverse|alternate-reverse)$/
          styles[:direction] = item
        when /^(?:none|forwards|backwards|both)$/
          styles[:fill_mode] = item
        when /^(?:running|paused)$/
          styles[:play_state] = item
        when /^(?:[\d\.]+|infinite)$/
          styles[:iteration_count] = item
        when R_TIMING_FUNCTION
          styles[:timing_function] = item
        else
          next
        end
        true
      end
      styles[:name] = items.shift
      styles[:timing_function] = items.shift
      # set defaults if we missed anything...
      styles = set_default_styles(styles, 'animation', properties)
      # make the styles available to the calling context
      styles
    end

    if reconstruct
      value = extrapolate_shorthand_animation(styles)
      # if the value came back nil, we were missing something, so throw a warning...
      return warn_not_enough_infomation_to_derive(property) if value.nil?
      return value
    end

    # otherwise just return the value we were asked for
    return styles
  end

end
