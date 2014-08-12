module Archetype::SassExtensions::Styleguide

  #
  # exposes the grammar used when interpreting styleguide calls
  #
  # *Parameters*:
  # - <tt>sentence</tt> {String|List} the sentence describing the component
  # - <tt>theme</tt> {String} the theme to use
  # - <tt>state</tt> {String} the name of a state to return
  # *Returns*:
  # - {Map} a map including the `identifier` and `modifiers`
  def _styleguide_grammar(sentence, theme = nil, state = nil)
    keys = ['identifier', 'modifiers', 'token']
    id, modifiers, token = grammar(sentence, theme, state)

    # if the id is empty, then it means that the sentence didn't contain a valid component id
    # so we set everything to `null`
    unless id
      id = null
      modifiers = null
    # otherwise we ensure that we're sending back appropriate values
    else
      id = identifier(id)
      modifiers = modifiers.empty? ? null : list(modifiers.map{|m| identifier(m)}, :space)
    end

    return Sass::Script::Value::Map.new({
      identifier('identifier') => id,
      identifier('modifiers') => modifiers
    });
  end

  private

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
    _styleguide_debug "converting `#{sentence}` to grammar", :grammar
    theme = get_theme(theme)
    components = theme[:components]
    # get a list of valid ids
    styleguideIds = components.keys

    # convert the sentence to a string and then split into an array
    # this ensures that all the pieces are treated as strings and not other primitive types (e.g. a list of strings in the middle of a sentence)
    sentence = helpers.to_str(sentence).split

    id, modifiers = grammarize(sentence, styleguideIds)

    # if there was no id, return a list of valid IDs for reporting
    modifiers = styleguideIds if id.nil?
    # get the list of currenty installed component extensions
    extensions = theme[:extensions] if not id.nil?
    # TODO - low - eoneill: make sure we always want to return unique modifiers
    # i can't think of a case where we wouldn't want to remove dups
    # maybe in the case where we're looking for strict keys on the lookup?
    modifiers = modifiers.uniq
    token = memoizer.tokenize(theme[:name], extensions, id, modifiers, state)
    if id
      _styleguide_debug "the computed grammar is...", :grammar
      _styleguide_debug "  identifier: #{id}", :grammar
      unless modifiers.empty?
        _styleguide_debug "  modifiers: #{modifiers.join(', ')}", :grammar
      end
    end
    return id, modifiers, token
  end

  #
  # given a sentence, convert it to it's internal representation
  #
  # *Parameters*:
  # - <tt>sentence</tt> {Array|List} the sentence describing the component
  # - <tt>ids</tt> {Array} the list of identifiers
  # *Returns*:
  # - {Array} an array containing the identifer and modifiers
  #
  def grammarize(sentence, ids = [])
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
        item = item.value if not item.is_a?(String)
        # find the ID
        if id.nil? and ids.include?(item) and prefix.empty? and order.empty?
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
    return id, modifiers
  end

end
