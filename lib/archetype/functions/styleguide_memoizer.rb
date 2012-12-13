# :stopdoc:
# This module implements a memoizer for caching styleguide() invocations.
#
module Archetype::Functions::StyleguideMemoizer
private
  # memoized store for components we've already computed
  @components ||= {}

  #
  # get the token for a styleguide reference given the current state of the theme
  #
  # *Parameters*:
  # - <tt>theme</tt> {String} the theme name
  # - <tt>extensions</tt> {Array} the list of currently installed extensions
  # - <tt>id</tt> {String} the component identifier
  # - <tt>modifiers</tt> {Array} the list of modifiers
  # - <tt>state</tt> {String} the name of the state
  # *Returns*:
  # - {Fixnum} whether or not the value is nil/blank
  #
  def self.tokenize(theme, extensions, id, modifiers, state)
    return nil if extensions.nil? or id.nil?
    return "#{id}::#{(modifiers.to_a.sort + extensions).join('$')}::#{state}".hash
  end

  #
  # add a value to the memoizer given a token
  #
  # *Parameters*:
  # - <tt>theme</tt> {String} the theme name
  # - <tt>token</tt> {Fixnum} the token to register
  # - <tt>value</tt> {Hash} the value to store
  #
  def self.add(theme, token, value)
    (@components[theme] ||= {})[token] = value if not Compass.configuration.environment.to_s.include?('dev')
  end

  #
  # fetch a value from the memoizer given a token
  #
  # *Parameters*:
  # - <tt>theme</tt> {String} the theme name
  # - <tt>token</tt> {Fixnum} the token to lookup
  # *Returns*:
  # - <tt>value</tt> {Hash} the value from the memoizer
  #
  def self.fetch(theme, token)
    return false if token.nil?
    return (@components[theme] ||= {})[token]
  end

  #
  # invalidate the entire memoizer for the theme
  #
  # *Parameters*:
  # - <tt>theme</tt> {String} the theme name
  #
  def self.clear(theme)
    @components[theme] = {}
  end
end
