# :stopdoc:
# this shims the Hash functionality to ensure we have an ordered hash guarantee
module Archetype
  if RUBY_VERSION < '1.9'
    require 'hashery/ordered_hash'
    class Hash < Hashery::OrderedHash
      include Archetype::Functions::Hash

      # make select behave like its 1.9+ counterpart
      def select
        hsh = ::Archetype::Hash.new
        self.each do |key, value|
          hsh[key] = value if yield(key, value)
        end
        return hsh
      end

      # make select! behave like its 1.9+ counterpart
      def select!
        self.each do |key, value|
          self.delete[key] unless yield(key, value)
        end
        return self
      end

      # make reject behave like its 1.9+ counterpart
      def reject
        hsh = ::Archetype::Hash.new
        self.each do |key, value|
          hsh[key] = value unless yield(key, value)
        end
        return hsh
      end

      # make reject! behave like its 1.9+ counterpart
      def reject!
        self.each do |key, value|
          self.delete[key] if yield(key, value)
        end
        return self
      end
    end
  else
    class Hash < ::Hash
      include Archetype::Functions::Hash
    end
  end
end
