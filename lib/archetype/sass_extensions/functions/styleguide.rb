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
  # returns the CSS differences between components
  #
  # *Parameters*:
  # - <tt>$original</tt> {String|List|Map} the description or map representation of the original component
  # - <tt>$other</tt> {String|List|Map} the description or map representation of the new component
  # *Returns*:
  # - {List} a key-value paired list of styles
  #
  def styleguide_diff(original, other)
    @@archetype_styleguide_mutex.synchronize do
      # normalize our input (for back-compat)
      original = normalize_styleguide_definition(original)
      other = normalize_styleguide_definition(other)
      # compute the difference
      diff = original.diff(other)
      # convert the individual messages in a comparison
      original_message = helpers.get_meta_message(original).sub(MESSAGE_PREFIX, '').sub(MESSAGE_SUFFIX, '')
      other_message = helpers.get_meta_message(other).sub(MESSAGE_PREFIX, '').sub(MESSAGE_SUFFIX, '')
      diff = helpers.add_meta_message(diff, "#{MESSAGE_PREFIX}#{original_message}` vs `#{other_message}#{MESSAGE_SUFFIX}")
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
    @@archetype_styleguide_mutex.synchronize do
      # normalize our input
      definition = normalize_styleguide_definition(definition)
      # get the computed styles
      return derived_style(definition, properties, format, strict)
    end
  end

end
