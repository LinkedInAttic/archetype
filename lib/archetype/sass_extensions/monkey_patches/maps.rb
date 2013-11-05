module Sass
  module Script
    module Tree
      class MapLiteral < Node
        protected
        def _perform(environment)
          keys = Set.new
          map = Sass::Script::Value::Map.new(Sass::Util.to_hash(pairs.map do |(k, v)|
            k, v = k.perform(environment), v.perform(environment)
            ## PATCH:begin
            # don't de-dupe the keys
            if keys.include?(k) and not Archetype::Patches::Maps.enabled?
              raise Sass::SyntaxError.new("Duplicate key #{k.inspect} in map #{to_sass}.")
            end
            ## PATCH:end
            keys << k
            [k, v]
          end))
          map.options = options
          map
        end
      end
    end
  end

  module Util
    def ordered_hash(*pairs_or_hash)
      require 'sass/util/ordered_hash' if ruby1_8?

      if pairs_or_hash.length == 1 && pairs_or_hash.first.is_a?(Hash)
        hash = pairs_or_hash.first
        return hash unless ruby1_8?
        return OrderedHash.new.merge hash
      end

      if Archetype::Patches::Maps.enabled?
        ## PATCH:begin
        # create the object we'll be returning
        hsh = ((ruby1_8?) ? (pairs_or_hash.is_a?(NormalizedMap) ? NormalizedMap : OrderedHash) : Hash).new

        dups = Set.new

        # for each pair...
        pairs_or_hash.each do |k, v|
          # if we don't have anything stored, just store it
          if hsh[k].nil?
            hsh[k] = v
          # otherwise...
          else
            # push the new value onto an array with the existing values
            hsh[k] = [hsh[k]] if not hsh[k].is_a? Array
            hsh[k].push(v)
            dups << k
          end
        end
        # now for each duplicate key we got...
        dups.each do |key|
          # convert it's array of values into a meta object
          hsh[key] = Archetype::Functions::Helpers.array_to_meta(hsh[key])
        end
        return hsh
        ## PATCH:end
      else
        ## original method
        return Hash[pairs_or_hash] unless ruby1_8?
        (pairs_or_hash.is_a?(NormalizedMap) ? NormalizedMap : OrderedHash)[*flatten(pairs_or_hash, 1)]
      end
    end
  end
end

class Array
  def options=(options)
    # do nothing, just don't blow up
  end
end

# interface to enable/disable the map patch
module Archetype::Patches::Maps
  def self.enabled?
    return @enabled
  end

  def self.enable
    @enabled = true
  end

  def self.disable
    @enabled = false
  end

  private
  @enabled ||= true
end
