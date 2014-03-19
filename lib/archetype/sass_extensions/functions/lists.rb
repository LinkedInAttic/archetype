#
# This module provides a set of Sass functions for working with Sass::Script::Value::List
#
module Archetype::SassExtensions::Lists
  #
  # replace an index in a list
  #
  # *Parameters*:
  # - <tt>$list</tt> {List} the list to replace from
  # - <tt>$value</tt> {\*} the value to replace (if nil, it's a removal)
  # - <tt>$idx</tt> {Number} the index to replace
  # - <tt>$separator</tt> {String} the separator to use [auto|comma|space]
  # *Returns*:
  # - {List} the list with replaced index
  #
  def list_replace(list, idx = false, value = nil, separator = nil)
    # return early if the index is invalid (no operation)
    return list if (!idx || is_null(idx).value || idx.value == false)
    separator ||= list.separator if list.is_a?(Sass::Script::Value::List)
    # cast and zero-index $idx
    idx = (idx.value) - 1
    # cast list to a ruby array
    list = list.to_a.dup
    # remove or replace the given value
    if value.nil? or value == null
      list.delete_at(idx)
    else
      list[idx] = value
    end
    return Sass::Script::Value::List.new(list, separator)
  end
  Sass::Script::Functions.declare :list_replace, [:list, :idx]
  Sass::Script::Functions.declare :list_replace, [:list, :idx, :value]
  Sass::Script::Functions.declare :list_replace, [:list, :idx, :value, :separator]

  #
  # remove an index from a list
  #
  # *Parameters*:
  # - <tt>$list</tt> {List} the list to remove from
  # - <tt>$idx</tt> {Number} the index to remove
  # - <tt>$separator</tt> {String} the separator to use [auto|comma|space]
  # *Returns*:
  # - {List} the list with removed index
  #
  def list_remove(list, idx = false, separator = nil)
    return list_replace(list, idx, nil, separator)
  end
  Sass::Script::Functions.declare :list_remove, [:list, :idx]
  Sass::Script::Functions.declare :list_remove, [:list, :idx, :separator]

  #
  # insert an item into a list
  #
  # *Parameters*:
  # - <tt>$list</tt> {List} the list to insert into
  # - <tt>$idx</tt> {Number} the index to insert at
  # - <tt>$value</tt> {\*} the value to insert
  # - <tt>$separator</tt> {String} the separator to use [auto|comma|space]
  # *Returns*:
  # - {List} the list with inserted value
  #
  def list_insert(list, idx = false, value = nil, separator = nil)
    value = nil if value == Sass::Script::String.new('nil')
    # return early if the index is invalid (no operation) or $value is `nil`
    return list if (not idx or idx == Sass::Script::Bool.new(false)) or value.nil?
    return list_replace(list, idx, value, separator, -1)
  end
  Sass::Script::Functions.declare :list_insert, [:list, :idx]
  Sass::Script::Functions.declare :list_insert, [:list, :idx, :value]
  Sass::Script::Functions.declare :list_insert, [:list, :idx, :value, :separator]

  #
  # add values(s) to a list
  #
  # *Parameters*:
  # - <tt>$list</tt> {List} the list operate to on
  # - <tt>$values</tt> {List|Number|String} the value(s) to add to the list
  # *Returns*:
  # - {List} the final list
  #
  def list_add(list, values)
    return list_math(list, values, :plus)
  end
  Sass::Script::Functions.declare :list_add, [:list, :values]

  #
  # subtract values(s) from a list
  #
  # *Parameters*:
  # - <tt>$list</tt> {List} the list operate to on
  # - <tt>$values</tt> {List|Number|String} the value(s) to subtract from the list
  # *Returns*:
  # - {List} the final list
  #
  def list_subtract(list, values)
    return list_math(list, values, :minus)
  end
  Sass::Script::Functions.declare :list_subtract, [:list, :values]

  #
  # multiply values(s) into a list
  #
  # *Parameters*:
  # - <tt>$list</tt> {List} the list operate to on
  # - <tt>$values</tt> {List|Number|String} the value(s) to multiply into the list
  # *Returns*:
  # - {List} the final list
  #
  def list_multiply(list, values)
    return list_math(list, values, :times)
  end
  Sass::Script::Functions.declare :list_multiply, [:list, :values]

  #
  # divide values(s) into a list
  #
  # *Parameters*:
  # - <tt>$list</tt> {List} the list operate to on
  # - <tt>$values</tt> {List|Number|String} the value(s) to divide into the list
  # *Returns*:
  # - {List} the final list
  #
  def list_divide(list, values)
    return list_math(list, values, :div)
  end
  Sass::Script::Functions.declare :list_divide, [:list, :values]

  #
  # list modulus value(s)
  #
  # *Parameters*:
  # - <tt>$list</tt> {List} the list to operate on
  # - <tt>$values</tt> {List|Number|String} the value(s) to modulus into the list
  # *Returns*:
  # - {List} the final list
  #
  def list_mod(list, values)
    return list_math(list, values, :mod)
  end
  Sass::Script::Functions.declare :list_mod, [:list, :values]

  #
  # joins a list into a string with the separator given
  #
  # *Parameters*:
  # - <tt>$list</tt> {List} the list operate to on
  # - <tt>$separator</tt> {String} the separator to insert between each item
  # *Returns*:
  # - {String} string conversions of all list item joined into one string
  #
  def list_join(list, separator = ', ')
    list = list.to_a
    separator = (separator.respond_to?(:value) ? separator.value : separator).to_s
    return identifier(list.join(separator))
  end
  Sass::Script::Functions.declare :list_join, [:list, :separator]

  #
  # find if any set of values is in a list
  # this is similar to `index()`, but allows $values to contain multiple values to test against
  #
  # *Parameters*:
  # - <tt>$haystack</tt> {List} input list
  # - <tt>$needle</tt> {List} the value(s) to search for
  # *Returns*:
  # - {Number|Boolean} if an item is found, returns the index, otherwise returns false
  #
  def index2(haystack, needle)
    haystack = haystack.to_a
    needle = needle.to_a
    index = haystack.index(haystack.detect { |i| needle.include?(i) })
    if index
      return number(index + 1)
    else
      return Sass::Script::Bool.new(false)
    end
  end
  Sass::Script::Functions.declare :index2, [:haystack, :needle]

  #
  # treats a list cyclically (never out of bounds, just wraps around)
  #
  # *Parameters*:
  # - <tt>$list</tt> {List} the list
  # - <tt>$idx</tt> {Number} the index
  # *Returns*:
  # - {*} the nth item in the List
  #
  def nth_cyclic(list, n = 1)
    n = n.to_i if n.is_a?(Sass::Script::Value::Number)
    list = list.to_a
    return list[(n - 1) % list.size]
  end
  Sass::Script::Functions.declare :nth_cyclic, [:list]
  Sass::Script::Functions.declare :nth_cyclic, [:list, :n]

  #
  # find a key within a nested list of ordered pairs
  #
  # *Parameters*:
  # - <tt>$list</tt> {List} the list to search in
  # - <tt>$key</tt> {String} the key identifier (name)
  # - <tt>$strict</tt> {Boolean} if true, does a strict match against the key
  # *Returns*:
  # - {*} the data associated with $key
  #
  def associative(list, key, strict = false)
    separator = list.separator if list.is_a?(Sass::Script::Value::List)
    list = helpers.list_to_hash(list)
    item = list[helpers.to_str(key, ' ' , :quotes)]
    item ||= list.first[1] if not strict
    return Sass::Script::Value::List.new([], separator) if item.nil?
    return helpers.hash_to_list(item, 0, separator) if item.is_a?(Array) or item.is_a?(Hash)
    # no conversion needed, so just return
    return item
  end
  Sass::Script::Functions.declare :associative, [:list, :key]
  Sass::Script::Functions.declare :associative, [:list, :key, :strict]

  #
  # extend a key-value paired list with another
  #
  # *Parameters*:
  # - <tt>$list</tt> {List} the list to extend to
  # - <tt>$extender</tt> {List} the list to extend with
  # *Returns*:
  # - <tt>$list</tt> {List} the extended list
  #
  def associative_merge(list, extender, kwargs = {})
    separator = list.separator if list.is_a?(Sass::Script::Value::List)
    list = helpers.list_to_hash(list)
    extender = helpers.list_to_hash(extender)
    list = list.rmerge(extender)
    return helpers.hash_to_list(list, 0, separator)
  end
  Sass::Script::Functions.declare :associative_merge, [:list, :extender]

  #
  # map collection items to conform to a well defined collection
  # this is primarily used to convert shorthand notations into symmetrical longhand notations
  #
  # *Parameters*:
  # - <tt>$list</tt> {List} input list
  # - <tt>$components</tt> {List} list of components
  # - <tt>$min</tt> {List} the minimum length of the collection
  # *Returns*:
  # - {List} formatted collection
  #
  def get_collection(list = bool(false), components = [], min = number(1))
    list = list.value ? list.to_a : components.to_a
    while(list.length < min.value)
      list = list.concat(list)
    end
    return list(list, :space)
  end
  Sass::Script::Functions.declare :get_collection, [:list]
  Sass::Script::Functions.declare :get_collection, [:components]
  Sass::Script::Functions.declare :get_collection, [:list, :min]
  Sass::Script::Functions.declare :get_collection, [:components, :min]
  Sass::Script::Functions.declare :get_collection, [:list, :components, :min]

  # Returns a list object from a value that was passed.
  # This can be used to unpack a space separated list that got turned
  # into a string by sass before it was passed to a mixin.
  #  this is shamelessly stolen from Compass :)
  #
  # *Parameters*:
  # - <tt>$arg</tt> {*} the item to cast to a list
  # *Returns*:
  # - <tt>$list</tt> {List} the item as a list
  #
  def _archetype_list(arg)
    # if it's already a list, just return it
    return arg if arg.is_a?(Sass::Script::Value::List)
    # otherwise, we'll try to cast it
    return list(arg, :space)
  end

  #
  # given a string of styles, convert it into a key-value pair list
  #
  # *Parameters*:
  # - <tt>$string</tt> {String} the string to convert
  # *Returns*:
  # - <tt>$list</tt> {List} the converted list of styles
  #
  def _style_string_to_list(string = '')
    # convert to string and strip all comments
    string = helpers.to_str(string, ' ').gsub(/\/\*[^\*\/]*\*\//, '')
    # then split it on each rule
    tmp = string.split(';')
    styles = []
    # and for each rule break it into it's key-value pairs
    tmp.each do |rule|
      kvp = []
      rule.split(':').each do |str|
        kvp.push identifier(str)
      end
      styles.push Sass::Script::Value::List.new(kvp, :comma)
    end
    # then recompose the list
    return Sass::Script::Value::List.new(styles, :comma)
  end

private

  #
  # perform math operations on a list
  #
  # *Parameters*:
  # - <tt>list</tt> {Sass::Script::Value::List} the list operate to on
  # - <tt>values</tt> {Sass::Script::Value::List|Sass::Script::Value::Number|Sass::Script::Value::String} the value(s) perform with
  # - <tt>method</tt> {Symbol} the method to perform [:plus|:minus|:times|:div|:mod]
  # *Returns*:
  # - {Sass::Script::Value::List} the final list
  #
  def list_math(list, values, method = :plus)
    separator = list.separator if list.is_a?(Sass::Script::Value::List)
    values = values.to_a
    list = list.to_a
    values.fill(values[0], 0..(list.size - 1)) if values.size < list.size
    list = [list, values].transpose.map do |x|
      x[0].method(method).call(x[1])
    end
    return Sass::Script::Value::List.new(list, separator)
  end
end
