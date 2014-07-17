require 'archetype/functions/styleguide_memoizer'
require 'thread'

%w(components constants grammar helpers resolve styles themes).each do |dep|
  require "archetype/sass_extensions/functions/styleguide/#{dep}"
end

#
# This is the magic of Archetype. This module provides the interfaces for constructing,
# extending, and retrieving reusable UI components
#
module Archetype::SassExtensions::Styleguide

  #
  # given a description of the component, convert it into CSS
  #
  # *Parameters*:
  # - <tt>$description</tt> {String|List|Map} the description of the component
  # - <tt>$theme</tt> {String} the theme to use
  # *Returns*:
  # - {Map} a map of styles
  #
  def _styleguide(description, state = nil, theme = nil)
    extras = []
    extras << "state: #{state}" unless (state.nil? or helpers.is_null(state))
    extras << "theme: #{theme}" unless (theme.nil? or helpers.is_null(theme))
    extras = extras.join(', ')
    msg = "`#{description}`"
    msg << " (#{extras})" unless extras.empty?
    _styleguide_debug "fetching styles for #{msg}", :get
    _styleguide_mutex_helper do
      styles = get_styles(description, theme, state)
      styles = resolve_runtime_locale_values(styles)
      _styleguide_debug "got styles for #{msg}", :get
      _styleguide_debug styles, :get
      # convert it back to a Sass:Map and carry on
      return helpers.hash_to_map(styles)
    end
  end

  #
  # returns the CSS differences between components
  #
  # *Parameters*:
  # - <tt>$original</tt> {String|List|Map} the description or map representation of the original component
  # - <tt>$other</tt> {String|List|Map} the description or map representation of the new component
  # *Returns*:
  # - {List} a key-value paired list of styles
  #
  def styleguide_diff(original, other)
    _styleguide_mutex_helper do
      # normalize our input (for back-compat)
      original = normalize_styleguide_definition(original)
      other = normalize_styleguide_definition(other)
      # compute the difference
      diff = original.diff(other)
      # convert the individual messages in a comparison
      original_message = helpers.get_meta_message(original).sub(MESSAGE_PREFIX, '').sub(MESSAGE_SUFFIX, '')
      other_message = helpers.get_meta_message(other).sub(MESSAGE_PREFIX, '').sub(MESSAGE_SUFFIX, '')
      diff = helpers.add_meta_message(diff, "#{MESSAGE_PREFIX}#{original_message}` vs `#{other_message}#{MESSAGE_SUFFIX}")
      _styleguide_debug "styleguide-diff", :diff
      _styleguide_debug diff, :diff
      # and return it as a map
      return helpers.hash_to_map(diff)
    end
  end

  #
  # given a styleguide definition or object, extract specified styles
  #
  # *Parameters*:
  # - <tt>$definition</tt> {String|List} the description of the component
  # - <tt>$properties</tt> {String|List} the properties to extract the derived styles for
  # - <tt>$format</tt> {String} the format to return the results in [auto|map|list]
  # - <tt>$strict</tt> {Boolean} if true, will only return an exact match, and not try to extrapolate the value
  # *Returns*:
  # - {List|Map|*} either a list/map of the values or the individual value itself
  #
  def styleguide_derived_style(definition, properties = [], format = 'auto', strict = false)
    _styleguide_mutex_helper do
      # normalize our input
      definition = normalize_styleguide_definition(definition)
      # get the computed styles
      return derived_style(definition, properties, format, strict)
    end
  end

end
