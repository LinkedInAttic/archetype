require 'thread'

module Archetype::SassExtensions::Util::Misc

  #
  # simple test for `null` or `nil` (deprecated) value. this is here for back-compat support with old `nil` syntax
  #
  # *Parameters*:
  # - <tt>$value</tt> {*} the value to test
  # *Returns*:
  # - {Boolean} whether or not the value is null
  #
  def is_null(value)
    return bool(helpers.is_null(value))
  end

  #
  # converts individual arguments into an archetype meta object that can be stored on a key in a map
  #
  # *Parameters*:
  # - <tt>args...</tt> {*} the values to put into the meta object
  # *Returns*:
  # - {Map} the meta object
  #
  def multiple_values(*args)
    return helpers.array_to_meta(args)
  end

  #
  # decorates a map so that the actual value can be resolved at runtime with the current locale
  #
  # *Parameters*:
  # - <tt>$map</tt> {*} the map to decorate
  # *Returns*:
  # - {Map} the decorated meta object
  #
  def runtime_locale_value(map)
    return helpers.meta_decorate(map, :runtime_locales)
  end

  #
  # given a map with meta data, extract the message and substitute any key-value pairs (@see str-substitute)
  #
  # *Parameters*:
  # - <tt>$map</tt> {Map} the map to observe
  # - <tt>$subsitutes</tt> {Map} the map of substitutes
  # *Returns*:
  # - {String} the meta message
  #
  def meta_message(map, subsitutes = nil)
    message = null
    meta = map_get_meta(map)
    message = str_substitute(map_get(meta, identifier(helpers::META[:message])), subsitutes) if not meta.value.nil?
    return message
  end

  #
  # check to see if a map key has multiple values
  #
  # *Parameters*:
  # - <tt>$map</tt> {Map} the map to observe
  # *Returns*:
  # - {Boolean} whether or not the map key represents multiple values
  #
  def has_multiple_values(map)
    meta = map_get_meta(map)
    return map_has_key(meta, identifier(helpers::META[:has_multiples])) if not meta.value.nil?
    return bool(false)
  end

  #
  # check to see if a value is decorated with runtime locale values
  #
  # *Parameters*:
  # - <tt>$value</tt> {*} the value to observe
  # *Returns*:
  # - {Boolean} whether or not the map is decorated with runtime locale values
  #
  def has_runtime_locale_value(value)
    meta = map_get_meta(value)
    return map_has_key(meta, identifier(helpers::META[:decorators][:runtime_locales])) if not meta.value.nil?
    return bool(false)
  end

  #
  # retrieve the archetype meta data from a map
  #
  # *Parameters*:
  # - <tt>$map</tt> {Map} the map to observe
  # *Returns*:
  # - {Map} the data contained within the meta key
  #
  def map_get_meta(map)
    if map.is_a?(Sass::Script::Value::Map) and map_has_key(map, identifier(helpers::META[:meta])).value
      return map_get(map, identifier(helpers::META[:meta]))
    end
    return null
  end

  #
  # given a map of styles, get the derived style of a given property
  #
  # *Parameters*:
  # - <tt>$styles</tt> {Map} the map of styles
  # - <tt>$properties</tt> {String|List} the properties to extract the derived styles for
  # - <tt>$format</tt> {String} the format to return the results in [auto|map|list]
  # - <tt>$strict</tt> {Boolean} if true, will only return an exact match, and not try to extrapolate the value
  # *Returns*:
  # - {List|Map|*} either a list/map of the values or the individual value itself
  #
  def derived_style(styles, properties = [], format = 'auto', strict = false)
    strict = strict.value if strict.respond_to?(:value)
    return Archetype::Functions::CSS.get_derived_styles(helpers.data_to_hash(styles), properties, helpers.to_str(format).to_sym, strict)
  end

  #
  # helper function to prevent routines from executing multiple times
  #
  # *Parameters*:
  # - <tt>$name</tt> {String} identifier to check/register
  # *Returns*:
  # - {Boolean} `true` if the first time invoked, `false` otherwise
  #
  def do_once(name)
    registry = do_once_registry
    # if it's already in the registry, just return `false`
    return bool(false) if registry.include?(name)
    # update the registry with the identifier
    registry = list(registry.dup.push(name), :comma)
    environment.global_env.set_var('REGISTRY_DO_ONCE', registry)
    # return true
    return bool(true)
  end

  #
  # generate a tag name with a prefix
  #
  # *Parameters*:
  # - <tt>$tag</tt> {String} the tag to prefix
  # - <tt>$prefix</tt> {String} the prefix to prepend to the tag
  # *Returns*:
  # - {String} the prefix joined with the tag
  #
  def prefixed_tag(tag, prefix = environment.var('CONFIG_GENERATED_TAG_PREFIX'))
    tag = tag.value
    tag = "-#{tag}" unless tag.empty?
    prefix = prefix.nil? ? 'x-archetype' : prefix.value
    return identifier("#{prefix}#{tag}")
  end
  Sass::Script::Functions.declare :prefixed_tag, [:tag]
  Sass::Script::Functions.declare :prefixed_tag, [:tag, :prefix]

  #
  # generate a unique token
  #
  # *Parameters*:
  # - <tt>$prefix</tt> {String} a string to prefix the UID with, `class` and `id` will generate a unique selector
  # *Returns*:
  # - {String} the unique string
  #
  def unique(prefix = '')
    prefix = helpers.to_str(prefix, ' ', :quotes)
    prefix = '.' if prefix == 'class'
    prefix = '#' if prefix == 'id'
    suffix = (defined?(ArchetypeTestHelpers) || defined?(Test::Unit)) ? "RANDOM_UID" : "#{Time.now.to_i}-#{rand(36**8).to_s(36)}-#{uid}"
    return identifier("#{prefix}archetype-uid-#{suffix}")
  end

  #
  # tokenize a given value
  #
  # *Parameters*:
  # - <tt>$item</tt> {*} the item to generate a unique hash from
  # *Returns*:
  # - {String} a token of the string
  #
  def tokenize(item)
    prefix = helpers.to_str(environment.var('CONFIG_GENERATED_TAG_PREFIX') || Archetype.name) + '-'
    token = prefix + item.hash.to_s
    return identifier(token)
  end
  Sass::Script::Functions.declare :tokenize, [:item]

  #
  # extracts the value associated with the current locale from the given decorated object
  #
  # *Parameters*:
  # - <tt>$item</tt> {*} the item check against
  # *Returns*:
  # - {*} the value given the current locale
  #
  def get_runtime_locale_value(item)
    item = helpers.hash_to_map(item) if item.is_a?(Hash)
    return item unless has_runtime_locale_value(item).value
    item = map_get(item, identifier('original')).to_h
    best_match = null
    item.each do |lang, value|
      if lang.value == 'default' or locale(lang).value
        best_match = value
      end
    end
    return best_match
  end

  def _archetype_within_mixin(contexts)
    stack = archetype_mixin_stack
    contexts = contexts.is_a?(Sass::Script::Value::List) ? contexts.to_a : [contexts]
    contexts.each do |context|
      return bool(true) if stack.include?(context.to_s.gsub(/_/, '-').downcase )
    end
    return bool(false)
  end

  def _archetype_mixin_called_recursively()
    stack = archetype_mixin_stack
    current = stack.shift
    return bool(stack.include?(current))
  end

  #
  # normalizes a property
  #
  # *Parameters*:
  # - <tt>$property</tt> {String} the property
  # *Returns*:
  # - {String} the normalized property
  #
  def _archetype_normalize_property(property)
    return null if helpers.is_null(property)
    property = helpers.to_str(property)
    return identifier(property.gsub(/\:.*/, ''))
  end

private

  @@archetype_ui_mutex = Mutex.new

  def uid
    @@archetype_ui_mutex.synchronize do
      @@uid ||= 0
      @@uid += 1
    end
  end

  def archetype_mixin_stack
    @environment.stack.frames.select {|f| f.is_mixin?}.reverse!.map! {|f| f.name.gsub(/_/, '-').downcase }
  end

  def do_once_registry
    (environment.var('REGISTRY_DO_ONCE') || []).to_a
  end

end