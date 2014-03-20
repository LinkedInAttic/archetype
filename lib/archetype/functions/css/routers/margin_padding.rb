module Archetype::Functions::CSS

  private

  #
  # router for `margin` properties
  #
  def self.get_derived_styles_router_for_margin(related, property)
    return get_derived_styles_router_for_margin_padding(related, property)
  end

  #
  # router for `padding` properties
  #
  def self.get_derived_styles_router_for_padding(related, property)
    return get_derived_styles_router_for_margin_padding(related, property)
  end

  #
  # (real) router for both `margin` and `padding` properties
  #
  def self.get_derived_styles_router_for_margin_padding(related, property)
    styles, reconstruct = with_each_available_relative_if_root(related, property) do |items, comma_separated|
      # blow away anything we've already discovered (because it's irrelevant)
      # and extract the top/right/bottom/left values
      # make the styles available to the calling context
      extract_symmetical_values(items)
    end
    # if we're getting the shorthand property, reconstruct the shorthand value
    if reconstruct
      value = extrapolate_shorthand_symmetrical(styles)
      # if the value came back nil, we were missing something, so throw a warning...
      return warn_not_enough_infomation_to_derive(property) if value.nil?
      return value
    end

    # otherwise just return the value we were asked for
    return styles
  end
end