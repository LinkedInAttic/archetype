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
      item_1, item_2 = self[key], other_hash[key]
      # special comparison for gradients
      are_gradients = (item_1.class == item_2.class) && (item_1.is_a?(Compass::Core::SassExtensions::Functions::GradientSupport::LinearGradient) or item_1.is_a?(Compass::Core::SassExtensions::Functions::GradientSupport::RadialGradient))
      eq_gradients = are_gradients ? (item_1.to_s == item_2.to_s) : true
      unless item_1 == item_2 and eq_gradients
        if item_1.kind_of?(Hash) and item_2.kind_of?(Hash)
          tmp[key] = item_1.diff(item_2)
        else
          tmp[key] = item_2 || Archetype::Functions::CSS.default(key)
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
