# :stopdoc:
# This module extends the native Ruby Hash class to support deep merging
# and comparing the difference between hashes.
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
  def rmerge(other_hash)
    new_hash = {}
    merge(other_hash) do |key, oldval, newval|
      new_hash[key] = oldval.class == self.class ? oldval.rmerge(newval) : newval
    end
  end

  #
  # adds the contents of other_hash to hsh, deep merged
  #
  # *Parameters*:
  # - +other_hash+ {Hash} the other hash to merge with
  # *Returns*:
  # - {Hash} the original hash with the addition of the contents of other_hash
  #
  def rmerge!(other_hash)
    merge!(other_hash) do |key, oldval, newval|
      oldval.class == self.class ? oldval.rmerge!(newval) : newval
    end
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
    (self.keys + other_hash.keys).uniq.inject({}) do |tmp, key|
      # special comparison for gradients
      are_gradients = self[key].is_a?(Compass::SassExtensions::Functions::GradientSupport::LinearGradient) and other_hash[key].is_a?(Compass::SassExtensions::Functions::GradientSupport::LinearGradient)
      eq_gradients = are_gradients ? (self[key].to_s == other_hash[key].to_s) : true
      unless self[key] == other_hash[key] and eq_gradients
        if self[key].kind_of?(Hash) && other_hash[key].kind_of?(Hash)
          tmp[key] = self[key].diff(other_hash[key])
        else
          tmp[key] = other_hash[key] || css_defaults(key)
          # if the key is `filter-gradient` and it was removed, we need to change the key to `ie-filter`
          tmp['ie-filter'] = css_defaults('ie-filter') if key == 'filter-gradient' and tmp[key].nil?
          # if it came back as `nil` we couldn't understand it or it has no default, so axe it
          tmp.delete(key) if tmp[key].nil?
        end
      end
      tmp
    end
  end

private
  #
  # returns a best guess for the default CSS value of a given property
  #
  # *Parameters*:
  # - <tt>key</tt> {String} the property to lookup
  # *Returns*:
  # - {Sass::String|Sass::Number} the default value
  #
  def css_defaults(key)
    if @css_defaults.nil?
      s = {}
      # color
      s['color'] = 'inherit'
      # text
      s['font'] = s['font-size'] = s['font-family'] = s['font-style'] = s['font-variant'] = s['font-weight'] = 'inherit'
      s['text-decoration'] = s['text-transform'] = 'none'
      s['text-align'] = 'left'
      s['text-indent'] = 0
      s['text-justify'] = 'auto'
      s['text-overflow'] = 'clip'
      s['line-height'] = 'normal'
      # backgrounds
      s['background'] = 'none'
      s['background-color'] = 'transparent'
      s['background-image'] = 'none'
      s['background-repeat'] = 'repeat'
      s['background-position'] = 'left top'
      s['background-attachment'] = 'scroll'
      s['background-clip'] = 'border-box'
      s['background-size'] = 'auto'
      s['background-origin'] = 'padding-box'
      # borders
      s['border'] = s['border-top'] = s['border-left'] = s['border-bottom'] = s['border-right'] = 'none'
      s['border-color'] = s['border-top-color'] = s['border-left-color'] = s['border-bottom-color'] = s['border-right-color'] = 'transparent'
      s['border-width'] = s['border-top-width'] = s['border-left-width'] = s['border-bottom-width'] = s['border-right-width'] = 0
      s['border-style'] = s['border-top-style'] = s['border-left-style'] = s['border-bottom-style'] = s['border-right-style'] = 'solid'
      # border-radius
      s['border-radius'] = s['border-top-left-radius'] = s['border-top-right-radius'] = s['border-bottom-left-radius'] = s['border-bottom-right-radius'] = 0
      # margin
      s['margin'] = s['margin-top'] = s['margin-left'] = s['margin-bottom'] = s['margin-right'] = 0
      # padding
      s['padding'] = s['padding-top'] = s['padding-left'] = s['padding-bottom'] = s['padding-right'] = 0
      # shadows
      s['text-shadow'] = s['box-shadow'] = 'none'
      # width/height
      s['height'] = s['width'] = 'auto'
      s['min-width'] = s['max-width'] = s['min-height'] = s['max-height'] = 'none'
      # position
      s['position'] = 'static'
      s['top'] = s['right'] = s['bottom'] = s['left'] = 'auto'
      s['clear'] = s['float'] = 'none'
      # misc
      s['overflow'] = 'visible'
      s['opacity'] = 1
      s['visibility'] = 'visible'
      s['ie-filter'] = 'gradient(enabled=false)'
      s['z-index'] = 0
      # --------------------
      @css_defaults = s
    end
    value = @css_defaults[key]
    value = Sass::Script::String.new(value) if value.is_a? String
    value = Sass::Script::Number.new(value) if value.is_a? Numeric
    return value
  end
end

class Hash
  include Archetype::Functions::Hash
end
