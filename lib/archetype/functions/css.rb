# :stopdoc:
module Archetype::Functions::CSS
  include Sass::Script::Value::Helpers

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
    'ie-filter'                   => :none,
    'border-top-radius'           => :zero,
    'border-right-radius'         => :zero,
    'border-bottom-radius'        => :zero,
    'border-left-radius'          => :zero
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
    helpers.warn("[#{Archetype.name}:css:default] cannot find a default value for `#{key}`") if value.nil?
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
    # TODO how to handle multiple values?
    computed = ::Archetype::Hash.new
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
  RS_BORDER_POSITION = '(-(?:top|right|bottom|left))'
  RS_BORDER_TYPE = '(-(?:color|width|style))'
  R_BORDER_STD = /^border#{RS_BORDER_POSITION}?#{RS_BORDER_TYPE}?$/
  R_BORDER_SHORTHANDS = /^border#{RS_BORDER_POSITION}?$/
  R_BORDER_IMG_OR_RADIUS = /(image|radius)/

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
    handler = "get_derived_styles_router_for_#{base}"
    # if we don't need any additional processing, stop here
    return nil if not self.respond_to?(handler)
    base = /^#{base}/
    value = self.method(handler).call(hsh.select { |key, value| key =~ base }, property)
    value = value[normalize_property_key(property)] if value.is_a?(Hash)
    return value
  end


  ## ------------------- #
  ## ROUTERS             #
  ## ------------------- #

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

  #
  # router for `border` and `border-{position}`
  #
  def self.get_derived_styles_router_for_border_shorthands(property, types, related)
    styles = ::Archetype::Hash.new
    types.each do |type|
      value = get_derived_styles_router_for_border(related, "#{property}-#{type}")
      if value
        styles[type.to_sym] = value
        return warn_cannot_disambiguate_property(property) if value.to_a.to_a.length > 1
      end
    end
    return nil if styles.empty?
    return Sass::Script::Value::List.new(extrapolate_shorthand_simple(styles, property, types), :space)
  end

  #
  # router for `border` properties
  #
  def self.get_derived_styles_router_for_border(related, property)
    properties = {
      :image  => %w(image-source image-slice image-width image-outset image-repeat),
      :radius => %w(top-left-radius top-right-radius bottom-right-radius bottom-left-radius)
    }
    positions = %w(top right bottom left)
    types = %w(width style color)

    # shorthand for `border` and `border-{position}` will extrapolate from other shorthands
    return get_derived_styles_router_for_border_shorthands(property, types, related) if property =~ R_BORDER_SHORTHANDS

    case_type = case property
    when R_BORDER_IMG_OR_RADIUS
      $1.to_sym
    when R_BORDER_STD
      :border
    end

    properties = properties[case_type] || []
    styles = ::Archetype::Hash.new
    augmented = false

    with_each_available_relative(related, property) do |key, value|
      items = value.to_a.dup

      case case_type
      when :image
        # border-image
        styles[normalize_property_key(key)] = value
        augmented = !is_root_property?(key)
        if !augmented
          styles = deconstruct_shorthand_for_border_image(items, properties)
        end
      when :radius
        # border-radius
        pieces = key.split('-')
        if pieces.length > 2
          augmented = true
          if pieces.length > 3
            # one of the longhand properties
            # e.g. `border-top-right-radius`
            styles[normalize_property_key(key)] = value
          else
            # one of the not-so-short shorthands
            # e.g. `border-top-radius` (these aren't real properties, but Compass supports these, so why not)
            position = pieces[1]
            positions = [
              ['top', 'bottom'],
              ['left', 'right']
            ]
            vertical = positions[0].include?(position)
            positions[vertical ? 1 : 0].each do |alt_position|
              str = "border-#{vertical ? position : alt_position}-#{vertical ? alt_position : position}-radius"
              styles[normalize_property_key(str)] = value
            end
          end
        else
          augmented = false
          shorthand = items.to_a
          # TODO - doesn't support vertical radius correctly
          styles = ::Archetype::Hash.new
          styles[:top_left_radius]      = shorthand[0],
          styles[:top_right_radius]     = shorthand[1] || shorthand[0],
          styles[:bottom_right_radius]  = shorthand[2] || shorthand[0],
          styles[:bottom_left_radius]   = shorthand[3] || shorthand[1] || shorthand[0]
        end
      when :border
        key =~ R_BORDER_STD
        position, type = $1, $2
        if position or type
          augmented = true
          if position and type
            # one of the longhand properties
            # e.g. `border-top-style`
            styles[normalize_property_key(key)] = value
          else
            # one of the not-so-short shorthands
            # e.g. `border-top` or `border-style`
            if position
              # e.g. `border-top`
              tmp = deconstruct_shorthand_for_border(items, types)
              types.each { |k| styles[normalize_property_key("#{key}-#{k}")] = tmp[k.to_sym] }
            else
              # e.g. `border-style`
              pattern = /^border#{RS_BORDER_POSITION}#{type}$/
              tmp = extract_symmetical_values(items)
              ALL_CSS_PROPERTIES.each { |k, v| styles[normalize_property_key(k)] = tmp[$1.gsub('-', '').to_sym] if k =~ pattern }
            end
          end
        else
          tmp = deconstruct_shorthand_for_border(items, types)
          positions.each do |pos|
            types.each { |k| styles[normalize_property_key("border-#{pos}-#{k}")] = tmp[k.to_sym] }
          end
        end
      end
    end
    pattern = /^border#{RS_BORDER_TYPE}$/

    styles = collapse_multi_value_lists(styles)

    if (augmented and is_root_property?(property)) or property =~ pattern
      value = nil
      case case_type
      when :image
        slash = Sass::Script::Value::String.new('/')
        styles = set_default_styles(styles, 'border-image', properties)
        value = [styles[:image_source], styles[:image_slice], slash, styles[:image_width], slash, styles[:image_outset], styles[:image_repeat]]
      when :border
        # e.g. border-color
        type = $1
        tmp = ::Archetype::Hash.new
        positions.each do |pos|
          key = "border-#{pos}#{type}"
          tmp[pos.to_sym] = styles[normalize_property_key(key)] || default(key)
        end
        return nil if tmp.empty?
        return extrapolate_shorthand_symmetrical(tmp)
      else
        # radius
        value = extrapolate_shorthand_simple(styles, property, properties)
      end
      return value ? Sass::Script::Value::List.new(value, :space) : nil
    end

    return styles[normalize_property_key(property)]
  end

  #
  # router for `overflow` properties
  #
  def self.get_derived_styles_router_for_overflow(related, property)
    return is_root_property?(property) ? nil : filter_available_relatives(related, property).values.last
  end

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

  #
  # router for `list-style` properties
  #
  def self.get_derived_styles_router_for_list(related, property)
    properties = %w(style-type style-position style-image)
    styles, reconstruct = with_each_available_relative_if_root(related, property) do |items, comma_separated|
      styles = ::Archetype::Hash.new
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
      styles
    end

    if reconstruct
      return nil if styles.nil? or styles.empty?
      styles = set_default_styles(styles, 'list', properties)
      value = [styles[:style_type], styles[:style_position], styles[:style_image]]
      # we simplify it if the values are all identical
      return value.first if value.uniq.length == 1
      return Sass::Script::Value::List.new(value, :space)
    end

    # otherwise just return the value we were asked for
    return styles
  end

  #
  # router for `outline` properties
  #
  def self.get_derived_styles_router_for_outline(related, property)
    properties = %w(color style width)
    styles, reconstruct = with_each_available_relative_if_root(related, property) do |items, comma_separated|
      # blow away anything we've already discovered (because it's irrelevant)
      styles = ::Archetype::Hash.new
      items.reject! do |item|
        if item.is_a?(Sass::Script::Value::Color)
          styles[:color] = item
        elsif item.is_a?(Sass::Script::Value::Number)
          styles[:width] = item
        else
          case helpers.to_str(item)
          when 'invert'
            styles[:color] = item
          when /^(?:none|hidden|dotted|dashed|solid|double|groove|ridge|inset|outset)$/
            styles[:style] = item
          when /^(?:thin|medium|thick)$/
            styles[:width] = item
          when 'inherit'
            next
          end
        end
        true
      end
      # at this point, we should only have `inherit` values left
      items.each do |item|
        if styles[:color].nil?
          styles[:color] = item
        elsif styles[:style].nil?
          styles[:style] = item
        else
          styles[:width] ||= item
        end
      end
      styles = set_default_styles(styles, 'outline', properties)
      # make the styles available to the calling context
      styles
    end

    if reconstruct
      return nil if styles.nil? or styles.empty?
      styles = set_default_styles(styles, 'outline', properties)
      return Sass::Script::Value::List.new([styles[:color], styles[:style], styles[:width]], :space)
    end

    # otherwise just return the value we were asked for
    return styles
  end


  ## ------------------- #
  ## SHORTHAND HELPERS   #
  ## ------------------- #

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

  #
  # deconstructs `border` shorthand properties into it's longhand values
  #
  def self.deconstruct_shorthand_for_border(items, types)
    tmp = ::Archetype::Hash.new
    items.reject! do |item|
      if item.is_a?(Sass::Script::Value::Number)
        tmp[:width] = item
      elsif item.is_a?(Sass::Script::Value::Color)
        tmp[:color] = item
      else
        case helpers.to_str(item)
        when /^(?:thin|medium|thick)$/
          tmp[:width] = item
        when /^(?:none|hidden|dotted|dashed|solid|double|groove|ridge|inset|outset)$/
          tmp[:style] = item
        else
          next
        end
      end
      true
    end
    items.each do |item|
      if helpers.to_str(item) == 'inherit'
        if tmp[:width].nil?
          tmp[:width] = item
        elsif tmp[:style].nil?
          tmp[:style] = item
        else
          tmp[:color] ||= item
        end
      end
    end
    return set_default_styles(tmp, 'border', types)
  end

  #
  # deconstructs `border-image` shorthand property into it's longhand values
  #
  def self.deconstruct_shorthand_for_border_image(items, properties)
    contexts = [:image_slice, :image_width, :image_outset]
    context = contexts.shift
    count = 1
    styles = ::Archetype::Hash.new
    items.each do |item|
      # source slice width outset repeat
      # <source> <slice {1,4}> / <width {1,4}> <outset> <repeat{1,2}>
      case helpers.to_str(item)
      when /^(?:url\(.*\)|none)$/
        styles[:image_source] = item
      when /^(?:stretch|repeat|round|space)$/
        styles[:image_repeat] ||= []
        styles[:image_repeat] << item
      when /(.+)\/(.+)/ # delimiter to denote which context (slice, width, outset) we're observing
        [$1, $2].each_with_index do |item, i|
          count -= 1 if item == 'fill' # don't count `fill`
          if count > 4 or i == 1
            context = contexts.shift
            count = 1
          end
          if context
            item = (item =~ /^(\d+(?:\.\d+)?)(.*)/) ? Sass::Script::Value::Number.new($1.to_f, [$2]) : Sass::Script::Value::String.new(item)
            styles[context] ||= []
            styles[context] << item
            count += 1
          end
        end
      when /^\d+/
        # if we've reached out limit for the current context, adjust
        if count > 4
          context = contexts.shift
          count = 1
        end
        # if we have a context, stash the value onto it
        if context
          styles[context] ||= []
          styles[context] << item
          count += 1
        end
      when /^fill$/
        styles[:image_slice] ||= []
        styles[:image_slice] << item
         # don't count `fill`
      when /^auto$/
        styles[:image_width] ||= []
        styles[:image_width] << item
        count += 1
      when '/'
        context = contexts.shift
        count = 1
      else
        next
      end
      true
    end
    styles = set_default_styles(styles, 'border-image', properties)
  end

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


  ## ------------------- #
  ## HELPERS             #
  ## ------------------- #

  #
  # output a warning about a disambiguous property found that can't be fully derived
  #
  # *Parameters*:
  # - <tt>property</tt> {String} the property
  # - <tt>info</tt> {String} additional info to display
  #
  def self.warn_cannot_disambiguate_property(property, info = nil)
    info = (info.nil? or info.empty?) ? '' : " (#{info})"
    return warn("[#{Archetype.name}:css:derive] cannot disambiguate the CSS property `#{property}#{info}`")
  end

  #
  # output a warning if there isn't enough information to derive the value requested
  #
  # *Parameters*:
  # - <tt>property</tt> {String} the property
  # *Returns*:
  # - {Sass::Null}
  #

  #
  def self.warn_not_enough_infomation_to_derive(property)
    return warn("[#{Archetype.name}:css:derive] there isn't enough information to derive `#{property}`, so returning `null`")
  end

  #
  # checks to see if a property is the root property or a descendent
  #
  # *Returns*:
  # - {Boolean} true if the property is a root property
  # *Returns*:
  # - {Sass::Null}
  #
  def self.is_root_property?(property)
    special_roots = %w(list-style border-image border-radius)
    return special_roots.push(get_property_base(property)).include?(property)
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
  def self.filter_available_relatives(related, property)
    handler = "filter_available_relatives_for_#{get_property_base(property)}"
    # handle special cases like `border`
    if self.respond_to?(handler)
      set = self.method(handler).call(related, property)
    else
      set = Set.new
      previous = nil
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
    end
    return related.select { |key, value| set.include?(key) }
  end

  #
  # filter relatives for `border`
  #
  def self.filter_available_relatives_for_border(related, property)
    set = Set.new
    set << property
    case property
    # border-radius and border-image
    when R_BORDER_IMG_OR_RADIUS
      match = $1
      if property == "border-#{match}" or match == 'radius'
        pattern = /^border-.*#{match}/
        ALL_CSS_PROPERTIES.each { |k,v| set << k if k =~ pattern }
      else
        set << "border-#{match}"
      end
    when R_BORDER_STD
      pattern = R_BORDER_STD
      if property != 'border'
        position, type = $1, $2
        if position
          if type
            # position and type
            # e.g. for border-top-width
            # we'll need: border, border-top, border-top-width, border-width
            pattern = /^(border|border#{position}(#{type})?$|border#{type})$/
          else
            # position only
            # e.g. for border-top
            # we'll need: border, border-top, border-top-{type}, border-{type}
            pattern = /^(border|border#{position}#{RS_BORDER_TYPE}?$|border#{RS_BORDER_TYPE})$/
          end
        else
          # type only
          # e.g. for border-width
          # we'll need: border, border-width, border-{position}-width, border-{position}
          pattern = /^(border|border#{RS_BORDER_POSITION}?#{type}$|border#{RS_BORDER_POSITION})$/
        end
      end
      ALL_CSS_PROPERTIES.each { |k,v| set << k if k =~ pattern }
    end
    return set
  end

  #
  # for each item in a given style object, if the value is an array, convert it to a Sass::List
  #
  # *Parameters*:
  # - <tt>styles</tt> {Hash} the styles
  # - <tt>separator</tt> {Symbol} the separator to use on the generated list
  # *Returns*:
  # - {Hash} the styles hash with updated values
  #
  def self.collapse_multi_value_lists(styles, separator = :space)
    styles.each do |key, value|
      if value.is_a?(Array)
        # if all the values are identical, we just need to return one
        styles[key] = value.uniq.length == 1 ? value.first : Sass::Script::Value::List.new(value, separator)
      end
    end
    return styles
  end

  #
  # normalizes the property into a key for use on a hash
  #
  # *Parameters*:
  # - <tt>property</tt> {String} the property to be used as a key
  # - <tt>base</tt> {String} the base of the property
  # *Returns*:
  # - {Symbol} the property normalized as a symbol
  #
  def self.normalize_property_key(property, base = nil)
    base ||= get_property_base(property)
    return property.gsub(/^#{Regexp.escape(base)}\-/, '').gsub('-', '_').to_sym
  end

  #
  # gets the base of a property
  #
  # *Parameters*:
  # - <tt>property</tt> {String} the property
  # *Returns*:
  # - {String} the base of the property
  #
  def self.get_property_base(property)
    return (property.match(/^([a-z]+)/) || [])[0]
  end

  #
  # extracts potential timing values from an array of values
  #
  # *Parameters*:
  # - <tt>value</tt> {Array} an array of Sass values
  # *Returns*:
  # - {Array} the extracted timing values
  #
  def self.get_timing_values(value)
    return value.select do |item|
      if item.is_a?(Sass::Script::Value::Number)
        unit = helpers.to_str(item.unit_str)
        ((item.unitless? and item.value == 0) or unit.include?('s'))
      end
    end
  end

  #
  # helper to iterate over each available relative property
  #
  # *Parameters*:
  # - <tt>related</tt> {Hash} the hash of styles
  # - <tt>property</tt> {String} the property to observe
  #
  def self.with_each_available_relative(related, property)
    filter_available_relatives(related, property).each do |key, value|
      yield(key, value) if block_given?
    end
  end

  #
  # helper to iterate over each available relative property, and executes a block if the property is a root property
  #
  # *Parameters*:
  # - <tt>related</tt> {Hash} the hash of styles
  # - <tt>property</tt> {String} the property to observe
  # *Returns*:
  # - {Hash} augmented styles hash
  #
  def self.with_each_available_relative_if_root(related, property)
    styles = ::Archetype::Hash.new
    augmented = false
    with_each_available_relative(related, property) do |key, value|
      styles[normalize_property_key(key)] = value
      augmented = !is_root_property?(key)
      # if it's the shorthand property...
      if !augmented
        styles = yield(value.to_a.dup, (value.is_a?(Sass::Script::Value::List) && value.separator == :comma)) if block_given?
      end
    end
    return styles, (augmented && is_root_property?(property))
  end

  #
  # given a styles object, sets default values for each property if not already set
  #
  # *Parameters*:
  # - <tt>styles</tt> {Hash} the styles
  # - <tt>base</tt> {String} the base string
  # - <tt>properties</tt> {Array} the properties to default if not set
  # *Returns*:
  # - {Hash} augmented styles hash
  #
  def self.set_default_styles(styles, base, properties)
    properties.each { |k| styles[normalize_property_key(k, base)] ||= default("#{base}-#{k}") }
    return styles
  end

  #
  # given a list of symmetrical values, extracts the [top right bottom left] key-value pairs
  #
  # *Parameters*:
  # - <tt>items</tt> {Array} the items
  # *Returns*:
  # - {Hash} the hash of [top right bottom left]
  #
  def self.extract_symmetical_values(items)
    return {
      :top        => items[0],
      :right      => items[1] || items[0],
      :bottom     => items[2] || items[0],
      :left       => items[3] || items[1] || items[0]
    }
  end

  #
  # wrapper to display a warning and return Sass::Null
  #
  # *Parameters*:
  # - <tt>msg</tt> {String} the message to display
  # *Returns*:
  # - {Sass::Null}
  #
  def self.warn(msg)
    helpers.warn msg
    return Sass::Script::Value::Null.new
  end

  def self.helpers
    @helpers ||= Archetype::Functions::Helpers
  end


end
