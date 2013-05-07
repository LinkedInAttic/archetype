# :stopdoc:
# This module provides a set of helper functions and methods for working with Sass literals.
#
module Archetype::Functions::Helpers
private

  #
  # provides a convenience interface to the Compass::Logger
  #
  def self.logger
    @logger ||= Compass::Logger.new
  end

  #
  # convert a Hash to a Sass::List
  #
  # *Parameters*:
  # - <tt>hsh</tt> {Hash} the hash to convert
  # - <tt>depth</tt> {Integer} the depth to walk down into the hash
  # - <tt>separator</tt> {Symbol} the separator to use for the Sass::List
  # *Returns*:
  # - {Sass::List} the converted list
  #
  def self.hash_to_list(hsh, depth = 0, separator = :comma)
    if hsh.is_a? Hash
      list = []
      hsh.each do |key, item|
        item = [key, item]
        # if its a hash, convert it to a List
        if item.is_a? Hash or item.is_a? Array
          tmp = []
          item[1] = [item[1]] if not item[1].is_a? Array
          item[1].each do |i|
            list.push Sass::Script::List.new([Sass::Script::String.new(item[0]), hash_to_list(i, depth + 1)], separator)
          end
        end
      end
      return Sass::Script::List.new(list, separator)
    end
    # if its an array, cast to a List
    return Sass::Script::List.new(hsh, separator) if hsh.is_a? Array
    # otherwise just return it
    return hsh
  end

  #
  # convert a Sass::List to a Hash
  #
  # *Parameters*:
  # - <tt>list</tt> {Sass::List} the list to convert
  # - <tt>depth</tt> {Integer} the depth to reach into nested Lists
  # - <tt>nest</tt> {Array} a list of keys to treat as nested objects
  # *Returns*:
  # - {Hash} the converted hash
  #
  def self.list_to_hash(list, depth = 0, nest = [], additives = [])
    list = list.to_a
    hsh = Archetype::Hash.new
    list.each do |item|
      item = item.to_a
      # convert the key to a string and strip off quotes
      key = to_str(item[0], ' ' , :quotes)
      value = item[1]
      if key != 'nil'
        # check if if it's a nesting hash
        nested = nest.include?(key)
        # if it's nested or we haven't reached out depth, recurse
        if nested or depth > 0
          value = list_to_hash(value, nested ? depth + 1 : depth - 1, nest, additives)
        end
        # update the hash key
        if not is_value(value, :blank)
          if additives.include?(key)
            hsh[key] ||= []
            hsh[key].push(value)
          else
            hsh[key] = value
          end
        end
      end
    end
    return hsh
  end

  #
  # convert things to a String
  #
  # *Parameters*:
  # - <tt>value</tt> {String|Sass::String|Sass::List} the thing to convert
  # - <tt>separator</tt> {String} the separator to use for joining Sass::List
  # *Returns*:
  # - {String} the converted String
  #
  def self.to_str(value, separator = ' ', strip = nil)
    value = value.is_a?(String) ? value : ((value.to_a).each{ |i| i.is_a?(String) ? i : i.value }).join(separator || '')
    strip = /\A"|"\Z/ if strip == :quotes
    return strip.nil? ? value : value.gsub(strip, '')
  end

  #
  # test a value for blankness or nilness
  #
  # *Parameters*:
  # - <tt>value</tt> {String|Array|Sass::String|Sass::List} the thing to test
  # - <tt>test</tt> {Symbol} the test to perform [:blank|:nil]
  # *Returns*:
  # - {Boolean} whether or not the value is nil/blank
  #
  def self.is_value(value, test = :nil)
    is_it = nil
    case test
    when :blank
      is_it = false
      value = value.value if value.is_a?(Sass::Script::String)
      is_it = value.empty? if value.is_a?(String)
      is_it = value.to_a.empty? if value.is_a?(Sass::Script::List) or value.is_a?(Array)
    when :nil
      is_it = false
      value = value.value if value.is_a?(Sass::Script::String)
      is_it = value == 'nil' if value.is_a?(String)
      is_it = to_str(value) == 'nil' if value.is_a?(Sass::Script::List) or value.is_a?(Array)
    end
    return is_it
  end
end
