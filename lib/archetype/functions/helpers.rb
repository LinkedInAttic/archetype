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
  # convert an Archetype::Hash to a Sass::Script::Value::List
  #
  # *Parameters*:
  # - <tt>hsh</tt> {Archetype::Hash} the hash to convert
  # - <tt>depth</tt> {Integer} the depth to walk down into the hash
  # - <tt>separator</tt> {Symbol} the separator to use for the Sass::Script::Value::List
  # *Returns*:
  # - {Sass::Script::Value::List} the converted list
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
            list.push Sass::Script::Value::List.new([Sass::Script::Value::String.new(item[0]), hash_to_list(i, depth + 1)], separator)
          end
        end
      end
      return Sass::Script::Value::List.new(list, separator)
    end
    # if its an array, cast to a List
    return Sass::Script::Value::List.new(hsh, separator) if hsh.is_a? Array
    # otherwise just return it
    return hsh
  end

  #
  # convert a Sass::Script::Value::List to an Archetype::Hash
  #
  # *Parameters*:
  # - <tt>list</tt> {Sass::Script::Value::List} the list to convert
  # - <tt>depth</tt> {Integer} the depth to reach into nested Lists
  # - <tt>nest</tt> {Array} a list of keys to treat as nested objects
  # - <tt>additives</tt> {Array} a list of keys that are additive
  # *Returns*:
  # - {Archetype::Hash} the converted hash
  #
  def self.list_to_hash(list, depth = 0, nest = [], additives = [])
    list = list.to_a
    previous = nil
    hsh = Archetype::Hash.new
    dups = Set.new
    list.each do |item|
      item = item.to_a

      # if a 3rd item exists, we probably forgot a comma or parens somewhere
      if previous.nil? and not item[2].nil?
        msg = "you're likely missing a comma or parens in your data structure"
        begin
          logger.record(:warning, "#{msg}: #{item}")
        rescue
          logger.record(:warning, msg)
        end
      end

      # convert the key to a string and strip off quotes
      key = to_str(item[0], ' ' , :quotes)
      # capture the value
      value = item[1]

      if key != 'nil'
        if is_value(value, :blank)
          if previous.nil?
            previous = key
            next
          else
            value = item[0]
            key = previous
            previous = nil
          end
        elsif not previous.nil?
          # if we got here, something is wrong with the structure
          list.shift if to_str(list[0]) == previous # remove the first item if it's the previous key, which is now the parent key
          list = list[0].to_a # now the remaining items were munged, so split them out
          hsh = Archetype::Hash.new
          hsh[previous] = list_to_hash(list, depth - 1, nest, additives)
          return hsh
        end
      end

      # update the hash if we have a valid key and hash
      if key != 'nil' and not is_value(value, :blank)
        # check if if it's a nesting hash
        nested = nest.include?(key)
        # if it's nested or we haven't reached out depth, recurse
        if nested or depth > 0
          value = list_to_hash(value, nested ? depth + 1 : depth - 1, nest, additives)
        end

        if additives.include?(key)
          hsh[key] ||= []
          hsh[key].push(value)
          dups << key
        else
          hsh[key] = value
        end
      end
    end

    dups.each do |key|
      # convert it's array of values into a meta object
      hsh[key] = self.array_to_meta(hsh[key])
    end

    logger.record(:warning, "one of your data structures is ambiguous, please double check near `#{previous}`") if not previous.nil?

    return hsh
  end

  #
  # convert a Sass::Script::Value::List or Sass::Script::Value::Map to an Archetype::Hash
  #
  # *Parameters*:
  # - <tt>data</tt> {Sass::Script::Value::List|Sass::Script::Value::Map} the data to convert
  # - <tt>depth</tt> {Integer} the depth to reach into nested Lists
  # - <tt>nest</tt> {Array} a list of keys to treat as nested objects
  # - <tt>additives</tt> {Array} a list of keys that are additive
  # *Returns*:
  # - {Archetype::Hash} the converted hash
  #
  def self.data_to_hash(data, depth = 0, nest = [], additives = [])
    method = data.is_a?(Sass::Script::Value::Map) ? :map_to_hash : :list_to_hash
    return self.method(method).call(data, depth, nest, additives)
  end

  #
  # converts a Sass::Script::Value::Map to an Archetype::Hash
  # - <tt>data</tt> {Sass::Script::Value::Map} the map to convert
  # - <tt>depth</tt> {Integer} the depth to reach into nested Lists
  # - <tt>nest</tt> {Array} a list of keys to treat as nested objects
  # - <tt>additives</tt> {Array} a list of keys that are additive
  # *Returns*:
  # - {Archetype::Hash} the converted hash
  #
  def self.map_to_hash(data, depth = 0, nest = [], additives = [])
    hsh = Archetype::Hash.new
    # recurisvely convert sub-maps into a hash
    data.to_h.each do |key, value|
      key = to_str(key, ' ' , :quotes)
      hsh[key] = value.is_a?(Sass::Script::Value::Map) ? map_to_hash(value) : value
    end
    return hsh
  end

  #
  # convert an Archetype::Hash to a Sass::Script::Value::Map
  #
  # *Parameters*:
  # - <tt>hsh</tt> {Archetype::Hash} the hash to convert
  # - <tt>depth</tt> {Integer} the depth to walk down into the hash
  # - <tt>separator</tt> {Symbol} the separator to use for the Sass::Script::Value::List
  # *Returns*:
  # - {Sass::Script::Value::List} the converted list
  #
  def self.hash_to_map(hsh)
    if hsh.is_a? Hash
      new_hsh = Archetype::Hash.new
      hsh.each do |key, item|
        new_hsh[Sass::Script::Value::String.new(key)] = (item.is_a? Hash) ? self.hash_to_map(item) : item
      end
    else
      new_hsh = {}
    end
    return Sass::Script::Value::Map.new(new_hsh)
  end

  #
  # convert an array of values into a Sass map with meta data
  #
  # *Example*:
  #   array_to_meta([1, "foo", "bar", 2, "baz"])
  #     #=> ((-archetype-meta: (has-multiple-values: true), values: (1, "foo", "bar", 2, "baz")))
  # *Parameters*:
  # - <tt>array</tt> {Array} the array to convert
  # *Returns*:
  # - {Sass::Script::Value::Map} the converted map
  #
  def self.array_to_meta(array)
    return array[0] if array.size == 1
    return Sass::Script::Value::Map.new({
      Sass::Script::Value::String.new('-archetype-meta') => Sass::Script::Value::Map.new({
        Sass::Script::Value::String.new('has-multiple-values') => Sass::Script::Value::Bool.new(true)
      }),
      Sass::Script::Value::String.new('values') => Sass::Script::Value::List.new(array, :comma)
    })
  end

  #
  # convert things to a String
  #
  # *Parameters*:
  # - <tt>value</tt> {String|Sass::Script::Value::String|Sass::Script::Value::List} the thing to convert
  # - <tt>separator</tt> {String} the separator to use for joining Sass::Script::Value::List
  # - <tt>strip</tt> {\*} the properties to strip from the resulting string
  # *Returns*:
  # - {String} the converted String
  #
  def self.to_str(value, separator = ' ', strip = nil)
    if not value.is_a?(String)
      value = ((value.to_a).each{ |i| i.nil? ? 'nil' : (i.is_a?(String) ? i : i.is_a?(Array) ? to_str(i, separator, strip) : i.value) }).join(separator || '')
    end
    strip = /\A"|"\Z/ if strip == :quotes
    return strip.nil? ? value : value.gsub(strip, '')
  end

  #
  # test a value for blankness or nilness
  #
  # *Parameters*:
  # - <tt>value</tt> {String|Array|Sass::Script::Value::String|Sass::Script::Value::List} the thing to test
  # - <tt>test</tt> {Symbol} the test to perform [:blank|:nil]
  # *Returns*:
  # - {Boolean} whether or not the value is nil/blank
  #
  def self.is_value(value, test = :nil)
    is_it = nil
    case test
    when :blank
      is_it = false
      value = value.value if value.is_a?(Sass::Script::Value::String)
      is_it = value.nil?
      is_it = value.empty? if value.is_a?(String)
      is_it = value.to_a.empty? if value.is_a?(Sass::Script::Value::List) or value.is_a?(Array)
    when :nil
      is_it = false
      value = value.value if value.is_a?(Sass::Script::Value::String)
      is_it = value.nil?
      is_it = value == 'nil' if value.is_a?(String)
      is_it = value.empty? if value.is_a?(Hash)
      is_it = to_str(value) == 'nil' if value.is_a?(Sass::Script::Value::List) or value.is_a?(Array)
    end
    return is_it
  end
end
