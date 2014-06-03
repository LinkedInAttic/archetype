require 'archetype/functions/helpers'

#
# This module provides a set of Sass functions for working with Sass::List
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
    return list if (not idx or idx == Sass::Script::Bool.new(false))
    separator ||= list.separator if list.is_a?(Sass::Script::List)
    # if $value is `nil`, make sure we can use it
    value = nil if value == Sass::Script::String.new('nil')
    # cast and zero-index $idx
    idx = (idx.value) - 1
    # cast list to a ruby array
    list = list.to_a
    # remove or replace the given value
    list.delete_at(idx) if value.nil?
    list[idx,1] = value if not value.nil?
    return Sass::Script::List.new(list, separator)
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
  # - <tt>$list</tt> {List} the list operate on
  # - <tt>$values</tt> {List|Number|String} the value(s) to add to the list
  # *Returns*:
  # - {List} the final list
  #
  def list_add(list, values)
    return list_math(list, values, :plus)
  end

  #
  # subtract values(s) from a list
  #
  # *Parameters*:
  # - <tt>$list</tt> {List} the list operate on
  # - <tt>$values</tt> {List|Number|String} the value(s) to subtract from the list
  # *Returns*:
  # - {List} the final list
  #
  def list_subtract(list, values)
    return list_math(list, values, :minus)
  end

  #
  # multiply values(s) into a list
  #
  # *Parameters*:
  # - <tt>$list</tt> {List} the list operate on
  # - <tt>$values</tt> {List|Number|String} the value(s) to multiply into the list
  # *Returns*:
  # - {List} the final list
  #
  def list_multiply(list, values)
    return list_math(list, values, :times)
  end

  #
  # divide values(s) into a list
  #
  # *Parameters*:
  # - <tt>$list</tt> {List} the list operate on
  # - <tt>$values</tt> {List|Number|String} the value(s) to divide into the list
  # *Returns*:
  # - {List} the final list
  #
  def list_divide(list, values)
    return list_math(list, values, :div)
  end

  #
  # list modulus value(s)
  #
  # *Parameters*:
  # - <tt>$list</tt> {List} the list operate on
  # - <tt>$values</tt> {List|Number|String} the value(s) to modulus into the list
  # *Returns*:
  # - {List} the final list
  #
  def list_mod(list, values)
    return list_math(list, values, :mod)
  end

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
      return Sass::Script::Number.new(index + 1)
    else
      return Sass::Script::Bool.new(false)
    end
  end

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
    n = n.to_i if n.is_a?(Sass::Script::Number)
    list = list.to_a
    return list[(n - 1) % list.size]
  end

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
    separator = list.separator if list.is_a?(Sass::Script::List)
    list = helpers.list_to_hash(list)
    item = list[helpers.to_str(key, ' ' , :quotes)]
    item ||= list.first[1] if not strict
    return Sass::Script::List.new([], separator) if item.nil?
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
    separator = list.separator if list.is_a?(Sass::Script::List)
    list = helpers.list_to_hash(list)
    extender = helpers.list_to_hash(extender)
    list = list.rmerge(extender)
    return helpers.hash_to_list(list, 0, separator)
  end
  Sass::Script::Functions.declare :associative_merge, [:list, :extender]

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
        kvp.push Sass::Script::String.new(str)
      end
      styles.push Sass::Script::List.new(kvp, :comma)
    end
    # the recompose the list
    return Sass::Script::List.new(styles, :comma)
  end

private
  def helpers
    @helpers ||= Archetype::Functions::Helpers
  end

  #
  # perform math operations on a list
  #
  # *Parameters*:
  # - <tt>list</tt> {Sass::List} the list operate on
  # - <tt>values</tt> {Sass::List|Sass::Number|Sass::String} the value(s) perform with
  # - <tt>method</tt> {Symbol} the method to perform [:plus|:minus|:times|:div|:mod]
  # *Returns*:
  # - {Sass::List} the final list
  #
  def list_math(list, values, method = :plus)
    separator = list.separator if list.is_a?(Sass::Script::List)
    values = values.to_a
    list = list.to_a
    values.fill(values[0], 0..(list.size - 1)) if values.size < list.size
    list = [list, values].transpose.map do |x|
      case method
      when :plus
        x[0].plus(x[1])
      when :minus
        x[0].minus(x[1])
      when :times
        x[0].times(x[1])
      when :div
        x[0].div(x[1])
      when :mod
        x[0].mod(x[1])
      end
    end
    return Sass::Script::List.new(list, separator)
  end
end
