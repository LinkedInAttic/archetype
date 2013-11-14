# :stopdoc:
# This module extends the native Ruby Hash class to support deep merging
# and comparing the difference between hashes.
# This functionality mimics that found in ActiveSupport
# @see https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/hash/deep_merge.rb
#
module Archetype::Functions::Hash
  #
  # recursively merge two hashes with deep merging
  #
  # *Parameters*:
  # - +other_hash+ {Hash} the other hash to merge with
  # *Returns*:
  # - {Hash} a new hash containing the contents of other_hash and the contents of hsh, deep merged
  #
  def rmerge(other_hash, &block)
    dup.rmerge!(other_hash, &block)
  end

  #
  # adds the contents of other_hash to hsh, deep merged
  #
  # *Parameters*:
  # - +other_hash+ {Hash} the other hash to merge with
  # *Returns*:
  # - {Hash} the original hash with the addition of the contents of other_hash
  #
  def rmerge!(other_hash, &block)
    other_hash.each_pair do |k,v|
      tv = self[k]
      if tv.is_a?(Hash) && v.is_a?(Hash)
        self[k] = tv.rmerge(v, &block)
      else
        self[k] = block && tv ? block.call(k, tv, v) : v
      end
    end
    return self
  end

  #
  # get the difference of another hash
  #
  # *Parameters*:
  # - +other_hash+ {Hash} the other hash to compare against
  # *Returns*:
  # - {Hash} a representation of the difference between the two hashes
  #
  def diff(other_hash)
    (self.keys + other_hash.keys).uniq.inject(Archetype::Hash.new) do |tmp, key|
      # special comparison for gradients
      are_gradients = self[key].is_a?(Compass::SassExtensions::Functions::GradientSupport::LinearGradient) and other_hash[key].is_a?(Compass::SassExtensions::Functions::GradientSupport::LinearGradient)
      eq_gradients = are_gradients ? (self[key].to_s == other_hash[key].to_s) : true
      unless self[key] == other_hash[key] and eq_gradients
        if self[key].kind_of?(Hash) && other_hash[key].kind_of?(Hash)
          tmp[key] = self[key].diff(other_hash[key])
        else
          tmp[key] = other_hash[key] || Archetype::Functions::CSS.default(key)
          # if the key is `filter-gradient` and it was removed, we need to change the key to `ie-filter`
          tmp['ie-filter'] = Archetype::Functions::CSS.default('ie-filter') if key == 'filter-gradient' and tmp[key].nil?
          # if it came back as `nil` we couldn't understand it or it has no default, so axe it
          tmp.delete(key) if tmp[key].nil?
        end
      end
      tmp
    end
  end
end

# this shims the Hash functionality to ensure we have an ordered hash guarantee
module Archetype
  if RUBY_VERSION < '1.9'
    require 'hashery/ordered_hash'
    class Hash < Hashery::OrderedHash
      include Archetype::Functions::Hash
    end
  else
    class Hash < ::Hash
      include Archetype::Functions::Hash
    end
  end
end
