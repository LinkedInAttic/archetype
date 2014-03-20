module Archetype::Functions::CSS

  private

  #
  # extrapolates shorthand value from a simple list of ordered properties
  #
  def self.extrapolate_shorthand_simple(styles, base, properties)
    styles = set_default_styles(styles, base, properties)
    value = []
    properties.each { |k| value << styles[normalize_property_key(k, base)] }
    return value
  end

  #
  # extrapolates shorthand value for symmetrical properties
  #
  def self.extrapolate_shorthand_symmetrical(styles)
    # make sure we have enough info to continue
    return nil if styles.nil? or styles.length < 4
    # can we use 3 values?
    if styles[:left] == styles[:right]
      # can we use 2 values?
      if styles[:bottom] == styles[:top]
        # can we use just 1 value?
        if styles[:top] == styles[:right]
          styles = [styles[:top]] # 1 value
        else
          styles = [styles[:top], styles[:right]] # 2 values
        end
      else
        styles = [styles[:top], styles[:right], styles[:bottom]] # 3 values
      end
    else
      styles = [styles[:top], styles[:right], styles[:bottom], styles[:left]] # 4 values
    end
    return Sass::Script::Value::List.new(styles, :space)
  end
end

%w(animation background border).each do |shorthand|
  require "archetype/functions/css/shorthands/#{shorthand}"
end
