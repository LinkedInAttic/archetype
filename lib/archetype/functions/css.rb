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
      value = Sass::Script::Value::List(value.map {|item| CSS_PRIMITIVES[item]}, :space)
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
    # TODO how to handle multiple values?
    computed = {}
    (properties || []).to_a.each do |property|
      value = Sass::Script::Value::Null.new
      if not property.value.nil?
        property = Archetype::Functions::Helpers.to_str(property, ' ', :quotes)
        # simple case, exact match only
        value = map[property] if map.key? property
        # otherwise, let's do some work...
        if not strict
          # if the property is a short- or long-hand, we need to figure out what the value actually is
          tmp = get_derived_styles_from_related(map, property)
          value = tmp if not tmp.nil?
        end
      end
      computed[property] = value
    end

    format = :map if computed.length > 1 and format == :auto

    case format
    when :map
      return Archetype::Functions::Helpers.hash_to_map(computed)
    when :list
      return Sass::Script::Value::List.new(computed.values, :comma)
    else
      return computed.values.first
    end
  end

private

  #
  # given a set of related properties, compute the property value
  #
  # *Parameters*:
  # - <tt>hsh</tt> {Hash} the hash of styles
  # - <tt>property</tt> {String} the original property we're looking for
  # *Returns*:
  # - {Hash} the derived styles
  #
  def self.get_derived_styles_from_related(hsh, property)
    # TODO: this doesn't support vendor prefixed properties (intentionally)
    base = property.match(/\A([a-z]+)/)
    if base and relatable_css_properties.include?(base[0])
      base = base[0]
      puts "base is #{base}..."
      handler = "handle_related_properties_#{base}"
      # if we know how to handle this property
      if self.respond_to?(handler)
        puts "found a handler for #{base}"
        base = /\A#{Regexp.escape(base)}/
        related = {}
        hsh.each do |key, value|
          related[key] = value if key =~ base
        end
        puts "  related properties for #{property} are #{related.inspect}"
        return self.method(handler).call(related, property)
      else
        disambiguate_warning(property)
      end
    end
    # if we got here, return nil
    return nil
  end

  #
  # get the list of all CSS properties as a string
  #
  # *Returns*:
  # - {String} all CSS properties
  #
  def self.all_css_properties
    @all_properties ||= ALL_CSS_PROPERTIES.keys.join(' ')
  end

  #
  # get a set of root CSS properties that have relative CSS properties
  #
  # *Returns*:
  # - {Set} the set of CSS properties
  #
  def self.relatable_css_properties
    if @relatable_css_properties.nil?
      related = Set.new
      all_css_properties.scan(/[\A\s]([a-z]+)[\s\Z]/).each do |match|
        related << match[0] if all_css_properties =~ /[\A\s]#{Regexp.escape(match[0])}-[^\s]+[\s\Z]/
      end
      @relatable_css_properties = related
      puts "#{related.inspect}"
    end
    return @relatable_css_properties
  end

  #
  # output a warning about a disambiguous property found that can't be fully derived
  #
  # *Parameters*:
  # - <tt>property</tt> {String} the property
  #
  def self.disambiguate_warning(property)
    Archetype::Functions::Helpers.logger.record(:warning, "Archetype doesn't currently know how to disambiguate the CSS property `#{property}`")
  end

  #
  # checks to see if a property is the root property or a descendent
  #
  # *Returns*:
  # - {Boolean} true if the property is a root property
  #
  def self.is_root_property?(property)
    puts "is #{property} is root" if !property.include?('-')
    return !property.include?('-')
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
    base = /[\A\s]#{Regexp.escape(property)}-[^\s]+[\s\Z]/
    related.each do |key, value|
      set << key if key =~ base
    end
    # special cases need to manipulate the set
    # border
    # TODO...

    final = {}
    related.each do |key, value|
      final[key] = value if set.include?(key)
    end
    return final
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

  ####

  #
  # handle cases where property values are symmetrically aligned to denote [top right bottom left]
  #
  def self.handle_related_symmetrical_properties(related, property)
    relatives = get_available_relatives(related, property)
    if is_root_property?(property)

    else

    end
  end

  ## handlers
  # animation background border margin overflow padding perspective target transition
  #
  # handles the `animiation` properties
  #
  def self.handle_related_properties_animation(related, property)
    # TODO
  end

  #
  # handles the `background` properties
  #
  def self.handle_related_properties_background(related, property)
    # TODO
  end

  #
  # handles the `border` properties
  #
  def self.handle_related_properties_border(related, property)
    # TODO
  end

  #
  # handles the `margin` properties
  #
  def self.handle_related_properties_margin(related, property)
    return handle_related_symmetrical_properties(related, property)
  end

  #
  # handles the `overflow` properties
  #
  def self.handle_related_properties_overflow(related, property)
    if not is_root_property?(property)
      return get_available_relatives(related, property).values.last
    end
    return nil
  end

  #
  # handles the `padding` properties
  #
  def self.handle_related_properties_padding(related, property)
    return handle_related_symmetrical_properties(related, property)
  end

  #
  # handles the `perspective` properties
  #
  def self.handle_related_properties_perspective(related, property)
    # TODO
  end

  #
  # handles the `target` properties
  #
  def self.handle_related_properties_target(related, property)
    # TODO
  end

  #
  # handles the `transition` properties
  #
  def self.handle_related_properties_transition(related, property)
    # TODO
  end

end
