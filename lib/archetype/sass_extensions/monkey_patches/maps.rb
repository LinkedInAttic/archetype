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
            ## PATCH:end
            keys << k
            [k, v]
          end))
          map.options = options
          map
        end
      end
    end

    module Functions
      def map_get(map, key)
        assert_type map, :Map
        value = to_h(map)[key] || null
        value = list(value, :comma) if value.is_a? Array
        return value
      end
      declare :map_get, [:map, :key]
    end

    # TODO: [maybe] we're not dealing with `map-values`, or `map-has-key` for now
  end

  module Util
    def ordered_hash(*pairs_or_hash)
      require 'sass/util/ordered_hash' if ruby1_8?

      if pairs_or_hash.length == 1 && pairs_or_hash.first.is_a?(Hash)
        hash = pairs_or_hash.first
        return hash unless ruby1_8?
        return OrderedHash.new.merge hash
      end

      ## PATCH:begin
      # create the object we'll be returning
      hsh = ((ruby1_8?) ? (pairs_or_hash.is_a?(NormalizedMap) ? NormalizedMap : OrderedHash) : Hash).new

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
        end
      end
      return hsh
      ## PATCH:end
    end
  end
end

class Array
  def options=(options)
    # do nothing, just don't blow up
  end
end
