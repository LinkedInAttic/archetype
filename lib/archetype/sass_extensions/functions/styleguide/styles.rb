module Archetype::SassExtensions::Styleguide

  private

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
    return Archetype::Hash.new if helpers.is_value(context, :nil) or context.empty?
    # push on the defaults first
    out = (strict ? resolve_dependents(id, context[modifiers], theme[:name], context) : context[DEFAULT]) || Archetype::Hash.new
    out = out.clone
    return Archetype::Hash.new if out == null
    # if it's not strict, find anything that matched
    if not strict
      modifiers = modifiers.split
      context.each do |key, definition|
        modifier = grammarize(key.split(' '))[1].join(' ')
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
            tmp = resolve_dependents(id, definition, theme[:name], nil, out)
            out, tmp = post_resolve_drops(out, tmp)
            out = out.rmerge(tmp) if not helpers.is_value(tmp, :nil)
          end
        end
      end
    end
    if out.is_a? Hash
      # recompose the special keys and extract any nested/inherited styles
      # this lets us define special states and elements
      SPECIAL.each do |special_key|
        special = out[special_key] || Archetype::Hash.new
        if special == null
          out[special_key] = Archetype::Hash.new
        else
          tmp = Archetype::Hash.new
          special.each { |key, value| tmp[key] = extract_styles(key, key, true, theme[:name], special) }
          out[special_key] = tmp if not tmp.empty?
        end
      end

      # check for nested styleguides
      styleguide = out[STYLEGUIDE]
      if not styleguide.nil?
        if helpers.is_value(styleguide, :hashy)
          styleguide = helpers.meta_to_array(styleguide)
        else
          styleguide = [styleguide]
        end
        if not styleguide.empty?
          styles = get_styles(styleguide, theme[:name])
          out.delete(STYLEGUIDE)
          out = styles.rmerge(out)
        end
      end
    end
    return out
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

    all_states = state.nil? || state == null || state == Sass::Script::Value::Bool::FALSE

    # debug message
    message = []
    message_extras = []

    # for each description, extract the associated styles
    description.to_a.each do |sentence|
      # if we have a hash, it denotes multiple values, so we need to convert this back to an array and recurse
      return get_styles(helpers.meta_to_array(sentence)) if helpers.is_value(sentence, :hashy)
      message << sentence
      # get the grammar from the sentence
      id, modifiers, token = grammar(sentence, theme, state)
      if id
        # check memoizer
        extracted = memoizer.fetch_or_create(theme, token) do
          # fetch additional styles
          extracted = extract_styles(id, modifiers, false, theme)
          # we can delete anything that had a value of `nil` as we won't be outputting those
          extracted.delete_if { |k,v| helpers.is_value(v, :nil) }
          # expose the result to the block
          extracted
        end
        styles = styles.rmerge(extracted)
      elsif not helpers.is_value(sentence, :nil)
        msg = modifiers.length > 0 ? "please specify one of: #{modifiers.sort.join(', ')}" : "there are no registered components"
        helpers.warn("[#{Archetype.name}:styleguide:identifier] `#{helpers.to_str(sentence)}` does not contain an identifier. #{msg}")
      end
    end

    message = message.join(', ')
    message_extras << "theme: #{theme}" if not theme.nil? and not [environment.var('CONFIG_THEME'), Archetype.name].include?(theme)
    message_extras << "state: #{state}" if not all_states
    if not message_extras.empty?
      message << " (#{message_extras.join(', ')})"
    end

    # now that we've collected all of our styles, if we requested a single state, merge that state upstream
    if not (all_states or styles[STATES].nil? or styles[STATES].empty?)
      state = helpers.to_str(state)
      state = styles[STATES][state]
      # remove any nested/special keys
      SPECIAL.each do |special|
        styles.delete(special)
      end
      styles = styles.merge(state) if not (state.nil? or state.empty?)
    end

    return helpers.add_meta_message(styles, "#{MESSAGE_PREFIX}#{message}#{MESSAGE_SUFFIX}")
  end

end
