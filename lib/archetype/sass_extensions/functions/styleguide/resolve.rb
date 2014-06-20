module Archetype::SassExtensions::Styleguide

  private

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
    # just return if it's nil
    return [obj, merger] if helpers.is_value(obj, :nil) or helpers.is_value(merger, :nil)
    # if it's a Sass::List, this is really an empty hash, so return a new hash
    return [obj, Archetype::Hash.new] if merger.is_a?(Sass::Script::Value::List)
    drop = merger[DROP]
    keys = obj.keys
    if not drop.nil?
      drop.to_a.each do |key|
        key = helpers.to_str(key)
        if not SPECIAL.include?(key)
          _styleguide_debug "dropping styles for `#{key}`", :drop
          obj.delete(key)
        end
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
    # suppress warnings from hashery (warning: multiple values for a block parameter (2 for 1))
    ::Sass::Util.silence_warnings do
      value.each do |key|
        value[key] = resolve_drops(value[key], obj[key], key, SPECIAL.include?(key)) if not value[key].nil?
      end
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
    _styleguide_debug "dropping styles for `#{key}`", :drop
    if SPECIAL.include?(key)
      if not (obj[key].nil? or obj[key].empty?)
        tmp[key] = Archetype::Hash.new
        tmp[key][DROP] = obj[key].keys
      end
    else
      tmp[key] = null
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
    return value if value.nil?
    debug = Compass.configuration.styleguide_debug
    # we have to create a clone here as the passed in value is volatile and we're performing destructive changes
    value = value.clone
    # check that we're dealing with a hash
    if value.is_a?(Hash)
      # check for dropped styles
      value = resolve_drops(value, obj)

      # check for inheritance
      inherit = value[INHERIT]
      if not inherit.nil?
        if helpers.is_value(inherit, :hashy)
          inherit = helpers.meta_to_array(inherit)
        else
          inherit = [inherit.to_a]
        end
        if not inherit.empty?
          # create a temporary object and extract the nested styles
          tmp = Archetype::Hash.new
          inherit.each do |related|
            _styleguide_debug "inheriting from `#{related}`", :inherit
            tmp = tmp.rmerge(extract_styles(id, related, true, theme, context))
          end
          # remove the inheritance key and update the styles
          value.delete(INHERIT)
          inherit = extract_styles(id, inherit, true, theme, context)
          value = inherit.rmerge(value)
          value = tmp.rmerge(value)
        end
      end
    end
    # return whatever we got
    _styleguide_debug "after resolving dependents...", :resolve
    _styleguide_debug value, :resolve
    return value
  end

  #
  # this helps to resolve any runtime locale values
  #
  def resolve_runtime_locale_values(hsh)
    hsh.each do |key, value|
      if value.is_a?(Hash)
        meta = value[helpers::META[:meta]]
        if meta && (meta.to_h)[helpers::META[:decorators][:runtime_locales]]
          hsh[key] = get_runtime_locale_value(value)
        else
          hsh[key] = resolve_runtime_locale_values(value)
        end
      end
    end
    return hsh
  end

end
