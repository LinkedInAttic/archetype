module Archetype::Functions::CSS

  private

  #
  # router for `overflow` properties
  #
  def self.get_derived_styles_router_for_overflow(related, property)
    return is_root_property?(property) ? nil : filter_available_relatives(related, property).values.last
  end
end