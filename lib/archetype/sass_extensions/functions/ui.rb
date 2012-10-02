require 'archetype/functions/helpers'

#
# This module provides some UI helper methods.
#
module Archetype::SassExtensions::UI
  #
  # generate a unique token
  #
  # *Parameters*:
  # - <tt>$prefix</tt> {String} a string to prefix the UID with, `class` and `id` will generate a unique selector
  # *Returns*:
  # - {String} the unique string
  #
  def unique(prefix = '')
    prefix = helpers.to_str(prefix).gsub(/\A"|"\Z/, '')
    prefix = '.' if prefix == 'class'
    prefix = '#' if prefix == 'id'
    return Sass::Script::String.new("#{prefix}archetype-uid-#{uid}")
  end

  #
  # parse a CSS content string and format it for injection into innerHTML
  #
  # *Parameters*:
  # - <tt>$content</tt> {String} the CSS content string
  # *Returns*:
  # - {String} the processed string
  #
  def _ie_pseudo_content(content)
    content = helpers.to_str(content)
    # escape &
    content = content.gsub(/\&/, '&amp;')
    # convert char codes (and remove single trailing whitespace if present) (e.g. \2079 -> &#x2079;)
    content = content.gsub(/\\([\da-zA-Z]{4})\s?/, '&#x\1;')
    # escape tags and cleanup quotes
    content = content.gsub(/\</, '&lt;').gsub(/\>/, '&gt;')
    # cleanup quotes
    content = content.gsub(/\A"|"\Z/, '').gsub(/\"/, '\\"')
    return Sass::Script::String.new(content)
  end

private
  def helpers
    @helpers ||= Archetype::Functions::Helpers
  end

  def uid
    @@uid ||= 0
    @@uid += 1
  end
end
