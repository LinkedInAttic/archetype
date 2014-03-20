module Archetype::Functions::CSS

  private

  #
  # extrapolates shorthand value for `animation` property
  #
  def self.extrapolate_shorthand_animation(styles)
    # make sure we have enough info to continue
    return nil if styles.nil? or styles[:name].nil?
    shorthand = []
    shorthand << styles[:name]
    %w(duration timing-function delay iteration-count direction fill-mode play-state).each do |k|
      shorthand << (styles[normalize_property_key(k, 'animation')] || default("animation-#{k}")).to_a.first
    end
    return Sass::Script::Value::List.new(shorthand, :space)
  end
end