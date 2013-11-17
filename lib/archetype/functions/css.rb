# :stopdoc:
module Archetype::Functions::CSS

  CSS_PRIMITIVES = {
    # common
    :inherit      => Sass::Script::Value::String.new('inherit'),
    :none         => Sass::Script::Value::String.new('none'),
    :auto         => Sass::Script::Value::String.new('auto'),
    :left         => Sass::Script::Value::String.new('left'),
    :top          => Sass::Script::Value::String.new('top'),
    :normal       => Sass::Script::Value::String.new('normal'),
    :repeat       => Sass::Script::Value::String.new('repeat'),
    :visible      => Sass::Script::Value::String.new('visible'),
    :scroll       => Sass::Script::Value::String.new('scroll'),
    :border_box   => Sass::Script::Value::String.new('border-box'),
    :padding_box  => Sass::Script::Value::String.new('padding-box'),
    :solid        => Sass::Script::Value::String.new('solid'),
    :static       => Sass::Script::Value::String.new('static'),
    :ease         => Sass::Script::Value::String.new('ease'),
    :running      => Sass::Script::Value::String.new('running'),
    :separate     => Sass::Script::Value::String.new('separate'),
    :stretch      => Sass::Script::Value::String.new('stretch'),
    :single       => Sass::Script::Value::String.new('single'),
    :inline_axis  => Sass::Script::Value::String.new('inline-axis'),
    :start        => Sass::Script::Value::String.new('start'),
    :content_box  => Sass::Script::Value::String.new('content-box'),
    :balance      => Sass::Script::Value::String.new('balance'),
    :medium       => Sass::Script::Value::String.new('medium'),
    :ltr          => Sass::Script::Value::String.new('ltr'),
    :inline       => Sass::Script::Value::String.new('inline'),
    :show         => Sass::Script::Value::String.new('show'),
    :outside      => Sass::Script::Value::String.new('outside'),
    :disc         => Sass::Script::Value::String.new('disc'),
    :invert       => Sass::Script::Value::String.new('invert'),
    :current      => Sass::Script::Value::String.new('current'),
    :window       => Sass::Script::Value::String.new('window'),
    :above        => Sass::Script::Value::String.new('above'),
    :flat         => Sass::Script::Value::String.new('flat'),
    :all          => Sass::Script::Value::String.new('all'),
    :baseline     => Sass::Script::Value::String.new('baseline'),

    # numbers
    :zero         => Sass::Script::Value::Number.new(0),
    :one          => Sass::Script::Value::Number.new(1),
    :p100         => Sass::Script::Value::Number.new(100, ['%']),
    :p100         => Sass::Script::Value::Number.new(50, ['%']),
    # colors
    :transparent  => Sass::Script::Value::Color.new([0, 0, 0, 0]),
    :black        => Sass::Script::Value::Color.new([0, 0, 0]),
  }


  # a list of all CSS properties
  ALL_CSS_PROPERTIES = {
    'animation'                   => [:none, :zero, :ease, :zero, :one, :normal],
    'animation-delay'             => :zero,
    'animation-direction'         => :normal,
    'animation-duration'          => :zero,
    'animation-fill-mode'         => :none,
    'animation-iteration-count'   => :one,
    'animation-name'              => :none,
    'animation-play-state'        => :running,
    'animation-timing-function'   => :ease,
    'appearance'                  => :normal,
    'backface-visibility'         => :visible,
    'background'                  => :none,
    'background-attachment'       => :scroll,
    'background-clip'             => :border_box,
    'background-color'            => :transparent,
    'background-image'            => :none,
    'background-origin'           => :padding_box,
    'background-position'         => [:left, :top],
    'background-repeat'           => :repeat,
    'background-size'             => :auto,
    'border'                      => :none,
    'border-bottom'               => :none,
    'border-bottom-color'         => :transparent,
    'border-bottom-left-radius'   => :zero,
    'border-bottom-right-radius'  => :zero,
    'border-bottom-style'         => :solid,
    'border-bottom-width'         => :zero,
    'border-collapse'             => :separate,
    'border-color'                => :transparent,
    'border-image'                => [:none, :p100, :one1, :zero, :stretch],
    'border-image-outset'         => :zero,
    'border-image-repeat'         => :stretch,
    'border-image-slice'          => :p100,
    'border-image-source'         => :none,
    'border-image-width'          => :zero,
    'border-left'                 => :none,
    'border-left-color'           => :transparent,
    'border-left-style'           => :solid,
    'border-left-width'           => :zero,
    'border-radius'               => :zero,
    'border-right'                => :none,
    'border-right-color'          => :transparent,
    'border-right-style'          => :solid,
    'border-right-width'          => :zero,
    'border-spacing'              => :inherit,
    'border-style'                => :solid,
    'border-top'                  => :none,
    'border-top-color'            => :transparent,
    'border-top-left-radius'      => :zero,
    'border-top-right-radius'     => :zero,
    'border-top-style'            => :solid,
    'border-top-width'            => :zero,
    'border-width'                => :zero,
    'bottom'                      => :auto,
    'box-align'                   => :stretch,
    'box-direction'               => :normal,
    'box-flex'                    => :zero,
    'box-flex-group'              => :one,
    'box-lines'                   => :single,
    'box-ordinal-group'           => :one,
    'box-orient'                  => :inline_axis,
    'box-pack'                    => :start,
    'box-shadow'                  => :none,
    'box-sizing'                  => :content_box,
    'caption-side'                => :top,
    'clear'                       => :none,
    'clip'                        => :auto,
    'color'                       => :inherit,
    'column-count'                => :auto,
    'column-fill'                 => :balance,
    'column-gap'                  => :normal,
    'column-rule'                 => [:medium, :none, :black],
    'column-rule-color'           => :black,
    'column-rule-style'           => :none,
    'column-rule-width'           => :width,
    'column-span'                 => :one,
    'column-width'                => :auto,
    'columns'                     => [:auto, :auto],
    'content'                     => :normal,
    'counter-increment'           => :none,
    'counter-reset'               => :none,
    'cursor'                      => :auto,
    'direction'                   => :ltr,
    'display'                     => :inline,
    'empty-cells'                 => :show,
    'float'                       => :none,
    'font'                        => :inherit,
    'font-family'                 => :inherit,
    'font-size'                   => :inherit,
    'font-size-adjust'            => :inherit,
    'font-stretch'                => :inherit,
    'font-style'                  => :inherit,
    'font-variant'                => :inherit,
    'font-weight'                 => :inherit,
    'grid-columns'                => :none,
    'grid-rows'                   => :none,
    'hanging-punctuation'         => :none,
    'height'                      => :auto,
    'icon'                        => :auto,
    'left'                        => :auto,
    'letter-spacing'              => :normal,
    'line-height'                 => :normal,
    'list-style'                  => [:disc, :outside, :none],
    'list-style-image'            => :none,
    'list-style-position'         => :outside,
    'list-style-type'             => :disc,
    'margin'                      => :zero,
    'margin-bottom'               => :zero,
    'margin-left'                 => :zero,
    'margin-right'                => :zero,
    'margin-top'                  => :zero,
    'max-height'                  => :none,
    'max-width'                   => :none,
    'min-height'                  => :none,
    'min-width'                   => :none,
    'nav-down'                    => :auto,
    'nav-index'                   => :auto,
    'nav-left'                    => :auto,
    'nav-right'                   => :auto,
    'nav-up'                      => :auto,
    'opacity'                     => :one,
    'outline'                     => [:invert, :none, :medium],
    'outline-color'               => :invert,
    'outline-offset'              => :zero,
    'outline-style'               => :none,
    'outline-width'               => :medium,
    'overflow'                    => :visible,
    'overflow-x'                  => :visible,
    'overflow-y'                  => :visible,
    'padding'                     => :zero,
    'padding-bottom'              => :zero,
    'padding-left'                => :zero,
    'padding-right'               => :zero,
    'padding-top'                 => :zero,
    'page-break-after'            => :auto,
    'page-break-before'           => :auto,
    'page-break-inside'           => :auto,
    'perspective'                 => :none,
    'perspective-origin'          => [:p50, :p50],
    'position'                    => :static,
    'punctuation-trim'            => :none,
    'quotes'                      => :inherit,
    'resize'                      => :none,
    'right'                       => :auto,
    'rotation'                    => :zero,
    'rotation-point'              => [:p50, :p50],
    'table-layout'                => :auto,
    'target'                      => [:current, :window, :above],
    'target-name'                 => :current,
    'target-new'                  => :window,
    'target-position'             => :above,
    'text-align'                  => :left,
    'text-decoration'             => :none,
    'text-indent'                 => :zero,
    'text-justify'                => :auto,
    'text-outline'                => :none,
    'text-overflow'               => :clip,
    'text-shadow'                 => :none,
    'text-transform'              => :none,
    'text-wrap'                   => :normal,
    'top'                         => :auto,
    'transform'                   => :none,
    'transform-origin'            => [:p50, :p50, :zero],
    'transform-style'             => :flat,
    'transition'                  => [:all, :zero, :ease, :zero],
    'transition-delay'            => :zero,
    'transition-duration'         => :zero,
    'transition-property'         => :all,
    'transition-timing-function'  => :ease,
    'unicode-bidi'                => :normal,
    'vertical-align'              => :baseline,
    'visibility'                  => :visible,
    'white-space'                 => :normal,
    'width'                       => :auto,
    'word-break'                  => :normal,
    'word-spacing'                => :normal,
    'word-wrap'                   => :normal,
    'z-index'                     => :zero,
    # archetype custom properties...
    'ie-filter'                   => :none
  }

  #
  # returns a best guess for the default CSS value of a given property
  #
  # *Parameters*:
  # - <tt>key</tt> {String} the property to lookup
  # *Returns*:
  # - {*} the default value
  #
  def self.default(key)
    value = ALL_CSS_PROPERTIES[key] || :invalid
    if value.is_a?(Array)
      value = Sass::Script::Value::List.new(value.map {|item| CSS_PRIMITIVES[item]}, :space)
    else
      value = CSS_PRIMITIVES[value]
    end
    helpers.logger.record(:warning, "cannot find a default value for `#{key}`") if value.nil?
    return value
  end

  #
  # calculates derived styles from a given map
  #
  # *Parameters*:
  # - <tt>map</tt> {Sass::Script::Value::Map} the map of styles
  # - <tt>properties</tt> {String|List|Array} the properties to extract the derived styles for
  # - <tt>format</tt> {String} the format to return the results in [auto|map|list]
  # - <tt>strict</tt> {Boolean} if true, will only return an exact match, and not try to extrapolate the value (TODO)
  # *Returns*:
  # - {*} the derived styles as either a list/map of the values or the individual value itself (based on the format)
  #
  def self.get_derived_styles(map, properties = [], format = :auto, strict = false)
    # TODO remove this after testing
    strict = false
    # TODO how to handle multiple values?
    computed = {}
    (properties || []).to_a.each do |property|
      value = Sass::Script::Value::Null.new
      if not property.value.nil?
        property = helpers.to_str(property, ' ', :quotes)
        # simple case, exact match only
        value = map[property] if map.key? property

        # if we're not doing strict matching...
        if not strict
          # if the property is a short- or long-hand, we need to figure out what the value actually is
          value = get_derived_styles_via_router(map, property) || value
        end
      end
      computed[property] = value
    end

    format = :map if computed.length > 1 and format == :auto

    case format
    when :map
      return helpers.hash_to_map(computed)
    when :list
      return Sass::Script::Value::List.new(computed.values, :comma)
    else
      return computed.values.first
    end
  end

private

  R_TIMING_FUNCTION = /^(?:linear|ease|ease-in|ease-out|ease-in-out|step-start|step-stop|steps\(.*\)|cubic-bezier\(.*\)|)$/

  def self.helpers
    @helpers ||= Archetype::Functions::Helpers
  end

  #
  # given a set of related properties, compute the property value
  #
  # *Parameters*:
  # - <tt>hsh</tt> {Hash} the hash of styles
  # - <tt>property</tt> {String} the original property we're looking for
  # *Returns*:
  # - {Hash} the derived styles
  #
  def self.get_derived_styles_via_router(hsh, property)
    base = get_property_base(property)
    handler = "handle_derived_properties_for_#{base}"
    # if we don't need any additional processing, stop here
    return nil if not self.respond_to?(handler)
    base = /^#{base}/
    return self.method(handler).call(hsh.select { |key, value| key =~ base }, property)
  end

  # TODO - doc
  def self.warn(msg)
    helpers.logger.record(:warning, msg)
  end

  #
  # output a warning about a disambiguous property found that can't be fully derived
  #
  # *Parameters*:
  # - <tt>property</tt> {String} the property
  #
  def self.warn_cannot_disambiguate_property(property)
    warn("Archetype doesn't currently know how to disambiguate the CSS property `#{property}`")
  end

  #
  # output a warning if there isn't enough information to derive the value requested
  #
  # *Parameters*:
  # - <tt>property</tt> {String} the property
  #
  def self.warn_not_enough_infomation_to_derive(property)
    warn("there isn't enough information to derive `#{property}`, so returning `null`")
  end

  #
  # checks to see if a property is the root property or a descendent
  #
  # *Returns*:
  # - {Boolean} true if the property is a root property
  #
  def self.is_root_property?(property)
    return property == get_property_base(property)
  end

  #
  # given a set of related properties, get the set of properties that are currently available
  #
  # *Parameters*:
  # - <tt>related</tt> {Hash} the hash of styles
  # - <tt>property</tt> {String} the property to observe
  # *Returns*:
  # - {Hash} the available related properties and their values
  #
  def self.get_available_relatives(related, property)
    previous = nil
    set = Set.new
    # find all potential parents (and self)
    property.split('-').each do |value|
      value = previous.nil? ? value : "#{previous}-#{value}"
      set << value
      previous = value
    end
    base = /(?:^|\s)#{Regexp.escape(property)}-[^\s]+(?:$|\s)/
    related.each do |key, value|
      set << key if key =~ base
    end
    # special cases need to manipulate the set
    # border
    # TODO...

    styles = {}
    related.each do |key, value|
      styles[key] = value if set.include?(key)
    end
    return styles
  end

  #
  # helper to iterate over each available relative property
  #
  # *Parameters*:
  # - <tt>related</tt> {Hash} the hash of styles
  # - <tt>property</tt> {String} the property to observe
  #
  def self.with_each_available_relative(related, property)
    get_available_relatives(related, property).each do |key, value|
      yield(key, value) if block_given?
    end
  end

  # TODO - doc
  def self.normalize_property_key(property, base = nil)
    base ||= get_property_base(property)
    return property.gsub(/^#{Regexp.escape(base)}\-/, '').gsub('-', '_').to_sym
  end

  # TODO - doc
  def self.get_property_base(property)
    return (property.match(/^([a-z]+)/) || [])[0]
  end

  # TODO - doc
  def self.get_timing_values(value)
    return value.select do |item|
      if item.is_a?(Sass::Script::Value::Number)
        unit = helpers.to_str(item.unit_str)
        ((item.unitless? and item.value == 0) or unit.include?('s'))
      end
    end
  end

  def self.with_each_relative_if_root(related, property)
    styles = {}
    augmented = false
    get_available_relatives(related, property).each do |key, value|
      # if it's the shorthand property...
      styles[normalize_property_key(key)] = value
      augmented = !is_root_property?(key)
      if !augmented
        styles = yield(value.to_a.clone, (value.is_a?(Sass::Script::Value::List) && value.separator == :comma)) if block_given?
      end
    end
    return styles, augmented
  end

  ####

  # TODO - doc
  def self.extrapolate_shorthand_simple(styles, base, properties)
    styles = set_default_styles(styles, base, properties)
    value = []
    properties.each { |k| value << styles[normalize_property_key(k, base)] }
    return value
  end

  # TODO - doc
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

  # TODO - doc
  def self.extrapolate_shorthand_margin_padding(styles)
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

  #
  # handle cases where property values denote [top right bottom left]
  #
  def self.handle_derived_properties_for_margin_padding(related, property)
    # we only care about the last piece of the property (e.g. `margin` or `top`)
    is_shorthand = is_root_property?(property)
    styles, augmented = with_each_relative_if_root(related, property) do |items, comma_separated|
      # blow away anything we've already discovered (because it's irrelevant)
      # and extract the top/right/bottom/left values
      # make the styles available to the calling context
      {
        :top        => items[0],
        :right      => items[1] || items[0],
        :bottom     => items[2] || items[0],
        :left       => items[3] || items[1] || items[0]
      }
    end
    # if we're getting the shorthand property, reconstruct the shorthand value
    if is_shorthand and augmented
      value = extrapolate_shorthand_margin_padding(styles)
      # if the value came back nil, we were missing something, so throw a warning...
      warn_not_enough_infomation_to_derive(property) if value.nil?
      return value
    end

    # otherwise just return the value we were asked for
    return styles[normalize_property_key(property)]
  end

  def self.set_default_styles(styles, base, properties)
    properties.each { |k| styles[normalize_property_key(k, base)] ||= default("#{base}-#{k}") }
    return styles
  end

  ## handlers

  #
  # handles the `animiation` properties
  #
  def self.handle_derived_properties_for_animation(related, property)
    properties = %w(name duration timing-function delay iteration-count direction play-state)
    is_shorthand = is_root_property?(property)
    styles, augmented = with_each_relative_if_root(related, property) do |items, comma_separated|
      # blow away anything we've already discovered (because it's irrelevant)
      # identify the items that are timing units
      timings = get_timing_values(items)
      items = items - timings
      # name duration timing-function delay iteration-count direction
      styles = {
        :duration => timings.shift,
        :delay    => timings.shift
      }
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

    if is_shorthand and augmented
      value = extrapolate_shorthand_animation(styles)
      # if the value came back nil, we were missing something, so throw a warning...
      warn_not_enough_infomation_to_derive(property) if value.nil?
      return value
    end

    # otherwise just return the value we were asked for
    return styles[normalize_property_key(property)]
  end

  #
  # handles the `background` properties
  #
  def self.handle_derived_properties_for_background(related, property)
    properties = %w(color position size repeat origin clip attachment image)
    property_order = [:color, :position, :size, :repeat, :origin, :clip, :attachment, :image]
    is_shorthand = is_root_property?(property)
    styles, augmented = with_each_relative_if_root(related, property) do |items, comma_separated|
      i = 0
      # blow away anything we've already discovered (because it's irrelevant)
      styles = {}
      properties.each { |k| styles[k.to_sym] = [] }

      (comma_separated ? items.to_a : [items]).each do |items|
        items = items.to_a.clone if items.respond_to?(:to_a)
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

      #color position size repeat origin clip attachment image
      # set defaults if we missed anything...

      # make the styles available to the calling context
      styles
    end

    if is_shorthand and augmented
      if styles.nil?
        warn_not_enough_infomation_to_derive(property)
        return nil
      end

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
    styles.each do |key, value|
      if value.is_a?(Array)
        # if all the values are identical, we just need to return one
        styles[key] = value.uniq.length == 1 ? value.first : Sass::Script::Value::List.new(value, :comma)
      end
    end

    # otherwise just return the value we were asked for
    return styles[normalize_property_key(property)]
  end

  #
  # handles the `border` properties
  #
  def self.handle_derived_properties_for_border(related, property)
    # TODO - implement
  end

  #
  # handles the `margin` properties
  #
  def self.handle_derived_properties_for_margin(related, property)
    return handle_derived_properties_for_margin_padding(related, property)
  end

  #
  # handles the `padding` properties
  #
  def self.handle_derived_properties_for_padding(related, property)
    return handle_derived_properties_for_margin_padding(related, property)
  end

  #
  # handles the `overflow` properties
  #
  def self.handle_derived_properties_for_overflow(related, property)
    return is_root_property?(property) ? nil : get_available_relatives(related, property).values.last
  end

  #
  # handles the `target` properties
  #
  def self.handle_derived_properties_for_target(related, property)
    properties = %w(name new position)
    is_shorthand = is_root_property?(property)
    relatives = get_available_relatives(related, property)
    styles, augmented = with_each_relative_if_root(related, property) do |items, comma_separated|
      # blow away anything we've already discovered (because it's irrelevant)
      # target-name target-new target-position
      styles = { :name => items.shift }

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
    if is_shorthand and augmented
      if styles.nil? or styles[:name].nil?
        warn_not_enough_infomation_to_derive(property)
        return nil
      end
      value = extrapolate_shorthand_simple(styles, 'target', properties)
      return Sass::Script::Value::List.new(value, :space)
    end

    # otherwise just return the value we were asked for
    return styles[normalize_property_key(property)]
  end

  #
  # handles the `transition` properties
  #
  def self.handle_derived_properties_for_transition(related, property)
    is_shorthand = is_root_property?(property)
    properties = %w(property duration timing-function delay)
    styles, augmented = with_each_relative_if_root(related, property) do |items, comma_separated|
      # blow away anything we've already discovered (because it's irrelevant)
      timings = get_timing_values(items)
      items = items - timings
      # property duration timing-function delay
      styles = {
        :duration         => timings.shift,
        :delay            => timings.shift
      }
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

    if is_shorthand and augmented
      if styles.nil? or styles[:property].nil?
        warn_not_enough_infomation_to_derive(property) if not styles.empty?
        return nil
      end
      value = extrapolate_shorthand_simple(styles, 'transition', properties)
      return Sass::Script::Value::List.new(value, :space)
    end

    # otherwise just return the value we were asked for
    return styles[normalize_property_key(property)]
  end


  def self.handle_derived_properties_for_list(related, property)
    is_shorthand = property == 'list-style'
    properties = %w(style-type style-position style-image)
    styles = {}
    get_available_relatives(related, property).each do |key, value|
      # if it's the shorthand property...
      if key == 'list-style'
        styles = {}
        items = value.to_a.clone
        if helpers.to_str(items) == 'inherit'
          styles[:style_image] = styles[:style_type] = styles[:style_position] = items
        else
          items.reject! do |item|
            case helpers.to_str(item)
            when /^(?:armenian|circle|cjk-ideographic|decimal(?:-leading-zero)?|disc|georgian|hebrew|(?:hiragana|katakana)(?:-iroha)?|(?:lower|upper)-(?:alpha|greek|latin|roman)|square)$/
              styles[:style_type] = item
            when /^(?:inside|outside)$/
              styles[:style_position] = item
            when /^url\(.*\)$/
              styles[:style_image] = item
            else
              next
            end
            true
          end

          items.each do |item|
            case helpers.to_str(item)
            when 'none'
              if styles[:style_type].nil?
                styles[:style_type] = item
              else
                styles[:style_image] ||= item
              end
            when 'inherit'
              if styles[:style_type].nil?
                styles[:style_type] = item
              elsif styles[:style_type].nil?
                styles[:style_position] = item
              else
                styles[:style_image] ||= item
              end
            end
          end
        end
      else
        styles[normalize_property_key(key)] = value
      end
    end

    if is_shorthand
      return nil if styles.nil? or styles.empty?
      styles = set_default_styles(styles, 'list', properties)
      value = [styles[:style_type], styles[:style_position], styles[:style_image]]
      # we simplify it if the values are all identical
      return value.first if value.uniq.length == 1
      return Sass::Script::Value::List.new(value, :space)
    end

    # otherwise just return the value we were asked for
    return styles[normalize_property_key(property)]
  end

  def self.handle_derived_properties_for_outline
    # TODO - implement
  end
end
