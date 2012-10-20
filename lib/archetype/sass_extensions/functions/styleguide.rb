require 'archetype/functions/helpers'
require 'archetype/functions/styleguide_memoizer'

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
  # these are unique CSS keys that can be exploited to provide fallback functionality by providing a second value
  # e.g color: red; color: rgba(255,0,0, 0.8);
  FALLBACKS   = %w(background background-image background-color border border-bottom border-bottom-color border-color border-left border-left-color border-right border-right-color border-top border-top-color clip color layer-background-color outline outline-color)
  ADDITIVES   = FALLBACKS + [DROP, INHERIT, STYLEGUIDE]
  # :startdoc:

  #
  # interface for adding new components to the styleguide structure
  #
  # *Parameters*:
  # - <tt>$id</tt> {String} the component identifier
  # - <tt>$data</tt> {List} the component data object
  # - <tt>$default</tt> {List} the default data object (for extending)
  # - <tt>$theme</tt> {String} the theme to insert the component into
  # - <tt>$force</tt> {Boolean} if true, forcibly insert the component
  # *Returns*:
  # - {Boolean} whether or not the component was added
  #
  def styleguide_add_component(id, data, default = nil, theme = nil, force = false)
    theme = get_theme(theme)
    components = theme[:components]
    id = helpers.to_str(id)
    # if force was true, we have to invalidate the memoizer
    memoizer.clear(theme[:name]) if force
    # if we already have the component, don't create it again
    return Sass::Script::Bool.new(false) if components[id] and not force and not Compass.configuration.environment.to_s.include?('dev')
    # otherwise add it
    components[id] = helpers.list_to_hash(default, 1, SPECIAL, ADDITIVES).merge(helpers.list_to_hash(data, 1, SPECIAL, ADDITIVES))
    return Sass::Script::Bool.new(true)
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
  # - <tt>$theme</tt> {String} the name of the extension
  # - <tt>$force</tt> {Boolean} if true, forcibly extend the component
  # *Returns*:
  # - {Boolean} whether or not the component was extended
  #
  def styleguide_extend_component(id, data, theme = nil, extension = nil, force = false)
    theme = get_theme(theme)
    components = theme[:components]
    id = helpers.to_str(id)
    # if force was set, we'll create a random token for the name
    extension = rand(36**8).to_s(36) if force
    # convert the extension into a hash (if we don't have an extension, compose one out of its data)
    extension = helpers.to_str(extension || data).hash
    extensions = theme[:extensions]
    return Sass::Script::Bool.new(false) if extensions.include?(extension) and not force and not Compass.configuration.environment.to_s.include?('dev')
    extensions.push(extension)
    components[id] = (components[id] ||= {}).rmerge(helpers.list_to_hash(data, 1, SPECIAL, ADDITIVES))
    return Sass::Script::Bool.new(true)
  end
  Sass::Script::Functions.declare :styleguide_extend_component, [:id, :data]
  Sass::Script::Functions.declare :styleguide_extend_component, [:id, :data, :theme]
  Sass::Script::Functions.declare :styleguide_extend_component, [:id, :data, :theme, :extension]

  #
  # given a description of the component, convert it into CSS
  #
  # *Parameters*:
  # - <tt>$description</tt> {String|List} the description of the component
  # - <tt>$theme</tt> {String} the theme to use
  # *Returns*:
  # - {List} a key-value paired list of styles
  #
  def styleguide(description, state = 'false', theme = nil)
    # convert it back to a Sass:List and carry on
    return helpers.hash_to_list(get_styles(description, theme, state), 0, FALLBACKS)
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
    original = get_styles(original, theme)
    other = get_styles(other, theme)
    diff = original.diff(other)
    return helpers.hash_to_list(diff, 0, FALLBACKS)
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
  def grammar(sentence, theme = nil, state = 'false')
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
      contexts = %w(in)
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
    context ||= theme[:components][id] || {}
    modifiers = helpers.to_str(modifiers)
    return {} if context.nil? or context.empty?
    # push on the defaults first
    out = (strict ? resolve_dependents(id, context[modifiers], theme[:name], context) : context[DEFAULT]) || {}
    out = out.clone
    # if it's not strict, find anything that matched
    if not strict
      modifiers = modifiers.split
      context.each do |definition|
        modifier = definition[0]
        if modifier != DEFAULT
          match = true
          modifier = modifier.split
          if modifier[0] == REGEX
            # if it's a regex pattern, test if it matches
            match = modifiers.join(' ') =~ /#{modifiers[1].gsub(/\A"|"\Z/, '')}/i
          else
            # otherwise, if the modifier isn't in our list of modifiers, it's not valid and just move on
            modifier.each { |i| match = false if not modifiers.include?(i) }
          end
          # if it matched, process it
          out = out.rmerge(resolve_dependents(id, definition[1], theme[:name], nil, out.keys)) if match
        end
      end
    end
    # recompose the special keys and extract any nested/inherited styles
    # this lets us define special states and elements
    SPECIAL.each do |special_key|
      if out.is_a? Hash
        special = out[special_key]
        tmp = {}
        (special || {}).each { |key, value| tmp[key] = extract_styles(key, key, true, theme[:name], special) }
        out[special_key] = tmp if not tmp.empty?
      end
    end
    # check for nested styleguides
    styleguide = out[STYLEGUIDE]
    if styleguide and not styleguide.empty?
      styles = get_styles(styleguide, theme[:name])
      out.delete(STYLEGUIDE)
      out = styles.rmerge(out)
    end
    return out
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
  def resolve_dependents(id, value, theme = nil, context = nil, keys = nil)
    # we have to create a clone here as the passed in value is volatile and we're performing destructive changes
    value = value.clone
    # check that we're dealing with a hash
    if value.is_a?(Hash)
      # check for dropped styles
      drop = value[DROP]
      if not drop.nil?
        tmp = {}
        if %w(all true).include?(helpers.to_str(drop)) and not keys.nil? and not keys.empty?
          keys.each do |key|
            tmp[key] = 'nil'
          end
        else
          drop = drop.to_a
          drop.each do |key|
            tmp[helpers.to_str(key)] = 'nil'
          end
        end
        value.delete(DROP)
        value = tmp.rmerge(value)
      end
      # check for inheritance
      inherit = value[INHERIT]
      if inherit and not inherit.empty?
        # create a temporary object and extract the nested styles
        tmp = {}
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
    @@styleguide_themes ||= {}
    theme_name = helpers.to_str(theme || 'archetype')
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
  # - <tt>description</tt> {String|List} the description of the component
  # - <tt>theme</tt> {String} the theme to use
  # - <tt>state</tt> {String} the name of a state to return
  # *Returns*:
  # - {Hash} the styles
  #
  def get_styles(description, theme = nil, state = 'false')
    state = helpers.to_str(state)
    description = description.to_a
    styles = {}
    description.each do |sentence|
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
    if state != 'false' and styles['states']
      state = styles['states'][state]
      # remove any nested/special keys
      SPECIAL.each do |special|
        styles.delete(special)
      end
      styles = styles.merge(state) if not (state.nil? or state.empty?)
    end
    return styles
  end
end
