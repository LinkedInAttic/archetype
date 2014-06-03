require 'archetype/functions/helpers'
require 'thread'

#
# This module provides some UI helper methods.
#
module Archetype::SassExtensions::UI
  # :stopdoc:
  @@archetype_ui_mutex = Mutex.new
  # :startdoc:

  #
  # generate a unique token
  #
  # *Parameters*:
  # - <tt>$prefix</tt> {String} a string to prefix the UID with, `class` and `id` will generate a unique selector
  # *Returns*:
  # - {String} the unique string
  #
  def unique(prefix = '')
    prefix = helpers.to_str(prefix, ' ', :quotes)
    prefix = '.' if prefix == 'class'
    prefix = '#' if prefix == 'id'
    suffix = Compass.configuration.testing ? "RANDOM_UID" : "#{Time.now.to_i}-#{rand(36**8).to_s(36)}-#{uid}"
    return Sass::Script::String.new("#{prefix}archetype-uid-#{suffix}")
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
    @@archetype_ui_mutex.synchronize do
      @@uid ||= 0
      @@uid += 1
    end
  end
end
