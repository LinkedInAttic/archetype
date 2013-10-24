require 'archetype/functions/helpers'
require 'archetype/functions/styleguide_memoizer'
require 'thread'

#
# This is the magic of Archetype. This module provides the interfaces for constructing,
# extending, and retrieving reusable UI components
#
module Archetype::SassExtensions::Styleguide

  # :stopdoc:
  INHERIT     = 'inherit'
  STYLEGUIDE  = 'styleguide'
  DROP        = 'drop'
  DEFAULT     = 'default'
  REGEX       = 'regex'
  SPECIAL     = %w(states selectors)
  DROPALL     = %w(all true)
  # these are unique CSS keys that can be exploited to provide fallback functionality by providing a second value
  # e.g color: red; color: rgba(255,0,0, 0.8);
  FALLBACKS   = %w(background background-image background-color border border-bottom border-bottom-color border-color border-left border-left-color border-right border-right-color border-top border-top-color clip color layer-background-color outline outline-color white-space extend)
  # these are mixins that make sense to run multiple times within a block
  MULTIMIXINS = %w(target-browser)
  ADDITIVES   = FALLBACKS + [DROP, INHERIT, STYLEGUIDE] + MULTIMIXINS
  @@archetype_styleguide_mutex = Mutex.new
  # :startdoc:

  #
  # interface for adding new components to the styleguide structure
  #
  # *Parameters*:
  # - <tt>$id</tt> {String} the component identifier
  # - <tt>$data</tt> {Map|List} the component data object
  # - <tt>$default</tt> {Map|List} the default data object (for extending)
  # - <tt>$theme</tt> {String} the theme to insert the component into
  # - <tt>$force</tt> {Boolean} if true, forcibly insert the component
  # *Returns*:
  # - {Boolean} whether or not the component was added
  #
  def styleguide_add_component(id, data, default = nil, theme = nil, force = false)
    @@archetype_styleguide_mutex.synchronize do
      theme = get_theme(theme)
      components = theme[:components]
      id = helpers.to_str(id)
      # if force was true, we have to invalidate the memoizer
      memoizer.clear(theme[:name]) if force
      # if we already have the component, don't create it again
      return Sass::Script::Bool.new(false) if component_exists(id, theme, nil, force)
      # otherwise add it
      components[id] = helpers.data_to_hash(default, 1, SPECIAL, ADDITIVES).merge(helpers.data_to_hash(data, 1, SPECIAL, ADDITIVES))
      return Sass::Script::Bool.new(true)
    end
  end
  Sass::Script::Functions.declare :styleguide_add_component, [:id, :data]
  Sass::Script::Functions.declare :styleguide_add_component, [:id, :data, :default]
  Sass::Script::Functions.declare :styleguide_add_component, [:id, :data, :default, :theme]

  #
  # interface for extending an existing components in the styleguide structure
  #
  # *Parameters*:
  # - <tt>$id</tt> {String} the component identifier
  # - <tt>$data</tt> {List} the component data object
  # - <tt>$theme</tt> {String} the theme to insert the component into
  # - <tt>$extension</tt> {String} the name of the extension
  # - <tt>$force</tt> {Boolean} if true, forcibly extend the component
  # *Returns*:
  # - {Boolean} whether or not the component was extended
  #
  def styleguide_extend_component(id, data, theme = nil, extension = nil, force = false)
    @@archetype_styleguide_mutex.synchronize do
      theme = get_theme(theme)
      components = theme[:components]
      id = helpers.to_str(id)
      # if force was set, we'll create a random token for the name
      extension = rand(36**8).to_s(36) if force
      # convert the extension into a hash (if we don't have an extension, compose one out of its data)
      extension = helpers.to_str(extension || data).hash
      extensions = theme[:extensions]
      return Sass::Script::Bool.new(false) if component_exists(id, theme, extension, force)
      extensions.push(extension)
      components[id] = (components[id] ||= Archetype::Hash.new).rmerge(helpers.data_to_hash(data, 1, SPECIAL, ADDITIVES))
      return Sass::Script::Bool.new(true)
    end
  end
  Sass::Script::Functions.declare :styleguide_extend_component, [:id, :data]
  Sass::Script::Functions.declare :styleguide_extend_component, [:id, :data, :theme]
  Sass::Script::Functions.declare :styleguide_extend_component, [:id, :data, :theme, :extension]

  #
  # check whether or not a component (or a component extension) has already been defined
  #
  # *Parameters*:
  # - <tt>$id</tt> {String} the component identifier
  # - <tt>$data</tt> {List} the component data object
  # - <tt>$theme</tt> {String} the theme to insert the component into
  # - <tt>$extension</tt> {String} the name of the extension
  # - <tt>$force</tt> {Boolean} if true, forcibly extend the component
  # *Returns*:
  # - {Boolean} whether or not the component/extension exists
  #
  def styleguide_component_exists(id, theme = nil, extension = nil, force = false)
    @@archetype_styleguide_mutex.synchronize do
      extension = helpers.to_str(extension).hash if not extension.nil?
      return Sass::Script::Bool.new( component_exists(id, theme, extension, force) )
    end
  end
  Sass::Script::Functions.declare :styleguide_extend_component, [:id]
  Sass::Script::Functions.declare :styleguide_extend_component, [:id, :theme]
  Sass::Script::Functions.declare :styleguide_extend_component, [:id, :theme, :extension]
  Sass::Script::Functions.declare :styleguide_extend_component, [:id, :theme, :extension, :force]

  #
  # given a description of the component, convert it into CSS
  #
  # *Parameters*:
  # - <tt>$description</tt> {String|List} the description of the component
  # - <tt>$theme</tt> {String} the theme to use
  # *Returns*:
  # - {List} a key-value paired list of styles
  #
  def _styleguide(description, state = nil, theme = nil)
    @@archetype_styleguide_mutex.synchronize do
      # convert it back to a Sass:List and carry on
      return helpers.hash_to_map(get_styles(description, theme, state))
    end
  end

  #
  # output the CSS differences between components
  #
  # *Parameters*:
  # - <tt>$original</tt> {String|List} the description of the original component
  # - <tt>$other</tt> {String|List} the description of the new component
  # - <tt>$theme</tt> {String} the theme to use
  # *Returns*:
  # - {List} a key-value paired list of styles
  #
  def styleguide_diff(original, other, theme = nil)
    @@archetype_styleguide_mutex.synchronize do
      original = helpers.data_to_hash(original)
      other = helpers.data_to_hash(other)
      diff = original.diff(other)
      return helpers.hash_to_map(diff)
    end
  end

  def component_registration_setup(type = nil)
    method = (type.nil?) ? :enable : :disable
    Archetype::Patches::Maps.method(method).call
    return Sass::Script::Bool.new(true)
  end

private
  def helpers
    @helpers ||= Archetype::Functions::Helpers
  end
  def memoizer
    Archetype::Functions::StyleguideMemoizer
  end

  #
  # given a sentence, deconstruct it into it's identifier and verbages
  #
  # *Parameters*:
  # - <tt>sentence</tt> {String|List} the sentence describing the component
  # - <tt>theme</tt> {String} the theme to use
  # - <tt>state</tt> {String} the name of a state to return
  # *Returns*:
  # - {Array} an array containing the identifer, modifiers, and a token
  #
  def grammar(sentence, theme = nil, state = nil)
    theme = get_theme(theme)
    components = theme[:components]
    # get a list of valid ids
    styleguideIds = components.keys
    sentence = sentence.split if sentence.is_a? String

    sentence = sentence.to_a
    id = nil
    modifiers = []
    if not sentence.empty?
      prefix = ''
      order = ''
      # these define various attributes for modifiers (e.g. `button with a shadow`)
      extras = %w(on with without)
      # these are things that are useless to us, so we just leave them out
      ignore = %w(a an also the this that is was it)
      # these are our context switches (e.g. `headline in a button`)
      contexts = %w(in within)
      sentence.each do |item|
        item = item.value
        # find the ID
        if id.nil? and styleguideIds.include?(item) and prefix.empty? and order.empty?
          id = item
        # if it's a `context`, we need to increase the depth and reset the prefix
        elsif contexts.include?(item)
          order = "#{item}-#{order}"
          prefix = ''
        # if it's an `extra`, we update the prefix
        elsif extras.include?(item)
          prefix = "#{item}-"
        # finally, check that it's not on the ignore (useless) list. if it is, we just skip over it
        # (maybe this should be the first thing we check?)
        elsif not ignore.include?(item)
          modifiers.push("#{order}#{prefix}#{item}")
        end
      end
    end
    # if there was no id, return a list of valid IDs for reporting
    modifiers = styleguideIds if id.nil?
    # get the list of currenty installed component extensions
    extensions = theme[:extensions] if not id.nil?
    # TODO - low - eoneill: make sure we always want to return unique modifiers
    # i can't think of a case where we wouldn't want to remove dups
    # maybe in the case where we're looking for strict keys on the lookup?
    modifiers = modifiers.uniq
    token = memoizer.tokenize(theme[:name], extensions, id, modifiers, state)
    return id, modifiers, token
  end

  #
  # interface for extracting styles in the styleguide references
  #
  # *Parameters*:
  # - <tt>id</tt> {String} the component identifier
  # - <tt>modifiers</tt> {Array} the component modifiers
  # - <tt>strict</tt> {Boolean} is it a strict lookup?
  # - <tt>theme</tt> {String} the theme to use
  # - <tt>context</tt> {Hash} the context to work in
  # *Returns*:
  # - {Hash} a hash of the extracted styles
  #
  def extract_styles(id, modifiers, strict = false, theme = nil, context = nil)
    theme = get_theme(theme)
    context ||= theme[:components][id] || Archetype::Hash.new
    modifiers = helpers.to_str(modifiers)
    return Archetype::Hash.new if context.nil? or context.empty?
    # push on the defaults first
    out = (strict ? resolve_dependents(id, context[modifiers], theme[:name], context) : context[DEFAULT]) || Archetype::Hash.new
    out = out.clone
    # if it's not strict, find anything that matched
    if not strict
      modifiers = modifiers.split
      context.each do |key, definition|
        definition = [key, definition]
        modifier = definition[0]
        if modifier != DEFAULT
          match = true
          modifier = modifier.split
          if modifier[0] == REGEX
            # if it's a regex pattern, test if it matches
            match = modifiers.join(' ') =~ /#{modifier[1].gsub(/\A"|"\Z/, '')}/i
          else
            # otherwise, if the modifier isn't in our list of modifiers, it's not valid and just move on
            modifier.each { |i| match = false if not modifiers.include?(i) }
          end
          # if it matched, process it
          if match
            tmp = resolve_dependents(id, definition[1], theme[:name], nil, out)
            out, tmp = post_resolve_drops(out, tmp)
            out = out.rmerge(tmp)
          end
        end
      end
    end
    # recompose the special keys and extract any nested/inherited styles
    # this lets us define special states and elements
    SPECIAL.each do |special_key|
      if out.is_a? Hash
        special = out[special_key] || Archetype::Hash.new
        if special == 'nil'
          out[special_key] = Archetype::Hash.new
        else
          tmp = Archetype::Hash.new
          special.each { |key, value| tmp[key] = extract_styles(key, key, true, theme[:name], special) }
          out[special_key] = tmp if not tmp.empty?
        end
      end
    end
    # check for nested styleguides
    styleguide = out[STYLEGUIDE]
    if not styleguide.nil?
      if styleguide.is_a?(Sass::Script::Value::Map)
        map = helpers.map_to_hash(styleguide)
        styleguide = map['values'].to_a
      else
        styleguide = [styleguide]
      end
      if not styleguide.empty?
        styles = get_styles(styleguide, theme[:name])
        out.delete(STYLEGUIDE)
        out = styles.rmerge(out)
      end
    end
    return out
  end

  #
  # given two objects, resolve the chain of dropped styles
  #  this runs after having already resolved the dropped styles and merged
  #
  # *Parameters*:
  # - <tt>obj</tt> {Hash} the source object
  # - <tt>merger</tt> {Hash} the object to be merged in
  # *Returns*:
  # - {Array.<Hash>} the resulting `obj` and `merger` objects
  #
  def post_resolve_drops(obj, merger)
    return [obj, merger] if obj.nil? or merger.nil?
    drop = merger[DROP]
    keys = obj.keys
    if not drop.nil?
      drop.to_a.each do |key|
        key = helpers.to_str(key)
        obj.delete(key) if not SPECIAL.include?(key)
      end
      merger.delete(DROP)
    end
    SPECIAL.each do |special|
      if obj[special].is_a?(Hash) and merger[special].is_a?(Hash)
        obj[special], merger[special] = post_resolve_drops(obj[special], merger[special])
      end
    end
    return [obj, merger]
  end

  #
  # given two objects, resolve the chain of dropped styles
  #
  # *Parameters*:
  # - <tt>value</tt> {Hash} the source object
  # - <tt>obj</tt> {Hash} the object to be merged in
  # - <tt>is_special</tt> {Boolean} whether this is from a SPECIAL branch of a Hash
  # *Returns*:
  # - {Array.<Hash>} the resulting value
  #
  def resolve_drops(value, obj, is_special = false)
    return value if not (value.is_a?(Hash) and obj.is_a?(Hash))
    keys = obj.keys
    drop = value[DROP]
    if not drop.nil?
      tmp = Archetype::Hash.new
      if DROPALL.include?(helpers.to_str(drop))
        if not keys.nil?
          keys.each do |key|
            special_drop_key(obj, tmp, key)
          end
        end
      else
        drop.to_a.each do |key|
          key = helpers.to_str(key)
          special_drop_key(obj, tmp, key)
        end
      end
      value.delete(DROP) if not is_special
      value = tmp.rmerge(value)
    end
    value.each do |key|
      value[key] = resolve_drops(value[key], obj[key], key, SPECIAL.include?(key)) if not value[key].nil?
    end
    return value
  end


  #
  # helper method for resolve_drops
  #
  # *Parameters*:
  # - <tt>obj</tt> {Hash} the object
  # - <tt>tmp</tt> {Hash} the temporary object
  # - <tt>key</tt> {String} the key we care about
  #
  def special_drop_key(obj, tmp, key)
    if SPECIAL.include?(key)
      if not (obj[key].nil? or obj[key].empty?)
        tmp[key] = Archetype::Hash.new
        tmp[key][DROP] = obj[key].keys
      end
    else
      tmp[key] = 'nil'
    end
  end

  #
  # resolve any dependent references from the component
  #
  # *Parameters*:
  # - <tt>id</tt> {String} the component identifier
  # - <tt>value</tt> {Hash} the current value
  # - <tt>theme</tt> {String} the theme to use
  # - <tt>context</tt> {Hash} the context to work in
  # - <tt>keys</tt> {Array} list of the external keys
  # *Returns*:
  # - {Hash} a hash of the resolved styles
  #
  def resolve_dependents(id, value, theme = nil, context = nil, obj = nil)
    # we have to create a clone here as the passed in value is volatile and we're performing destructive changes
    value = value.clone
    # check that we're dealing with a hash
    if value.is_a?(Hash)
      # check for dropped styles
      value = resolve_drops(value, obj)

      # check for inheritance
      inherit = (value[INHERIT] || []).to_a
      if not inherit.empty?
        # create a temporary object and extract the nested styles
        tmp = Archetype::Hash.new
        inherit.each { |related| tmp = tmp.rmerge(extract_styles(id, related, true, theme, context)) }
        # remove the inheritance key and update the styles
        value.delete(INHERIT)
        value = tmp.rmerge(value)
      end
    end
    # return whatever we got
    return value
  end

  #
  # keep a registry of styleguide themes
  #
  # *Parameters*:
  # - <tt>theme</tt> {String} the theme to use
  # *Returns*:
  # - {Hash} the theme
  #
  def get_theme(theme)
    theme_name = helpers.to_str(theme || environment.var('CONFIG_THEME') || 'archetype')
    @@styleguide_themes ||= {}
    theme = @@styleguide_themes[theme_name] ||= {}
    theme[:name] ||= theme_name
    theme[:components] ||= {}
    theme[:extensions] ||= []
    return theme
  end

  #
  # driver method for converting a sentence into a list of styles
  #
  # *Parameters*:
  # - <tt>description</tt> {String|List|Array} the description of the component
  # - <tt>theme</tt> {String} the theme to use
  # - <tt>state</tt> {String} the name of a state to return
  # *Returns*:
  # - {Hash} the styles
  #
  def get_styles(description, theme = nil, state = nil)
    styles = Archetype::Hash.new
    description.to_a.each do |sentence|
      # if we have a hash, it denotes multiple values, so we need to convert this back to an array and recurse
      return get_styles(helpers.meta_to_array(sentence)) if sentence.is_a?(Hash) or sentence.is_a?(Sass::Script::Value::Map)
      # get the grammar from the sentence
      id, modifiers, token = grammar(sentence, theme, state)
      if id
        # check memoizer
        memoized = memoizer.fetch(theme, token)
        if memoized
          styles = styles.rmerge(memoized)
        else
          # fetch additional styles
          extracted = extract_styles(id, modifiers, false, theme)
          # we can delete anything that had a value of `nil` as we won't be outputting those
          extracted.delete_if { |k,v| helpers.is_value(v, :nil) }
          styles = styles.rmerge(extracted)
          memoizer.add(theme, token, extracted)
        end
      elsif not helpers.is_value(sentence, :nil)
        helpers.logger.record(:warning, "[archetype:styleguide:missing_identifier] `#{helpers.to_str(sentence)}` does not contain an identifier. please specify one of: #{modifiers.sort.join(', ')}")
      end
    end
    # now that we've collected all of our styles, if we requested a single state, merge that state upstream
    if not (state.nil? or state.is_a?(Sass::Script::Value::Null) or state == Sass::Script::Value::Bool.new(false) or styles['states'].empty?)
      state = helpers.to_str(state)
      state = styles['states'][state]
      # remove any nested/special keys
      SPECIAL.each do |special|
        styles.delete(special)
      end
      styles = styles.merge(state) if not (state.nil? or state.empty?)
    end
    return styles
  end

  #
  # check whether or not a component (or a component extension) has already been defined
  #
  # *Parameters*:
  # - <tt>$id</tt> {String} the component identifier
  # - <tt>$data</tt> {List} the component data object
  # - <tt>$theme</tt> {String} the theme to insert the component into
  # - <tt>$extension</tt> {String} the name of the extension
  # - <tt>$force</tt> {Boolean} if true, forcibly extend the component
  # *Returns*:
  # - {Boolean} whether or not the component/extension exists
  #
  def component_exists(id, theme = nil, extension = nil, force = false)
    status = false
    theme = get_theme(theme) if not theme.is_a? Hash
    id = helpers.to_str(id)
    # determine the status of the component
    status = (extension.nil?) ? (not theme[:components][id].nil?) : theme[:extensions].include?(extension)
    return (status and not force and Compass.configuration.memoize)
  end
end
