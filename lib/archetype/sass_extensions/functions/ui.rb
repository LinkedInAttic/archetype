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
    suffix = defined?(Test::Unit) ? "RANDOM_UID" : "#{Time.now.to_i}-#{rand(36**8).to_s(36)}-#{uid}"
    return Sass::Script::Value::String.new("#{prefix}archetype-uid-#{suffix}")
  end

  #
  # tokenize a given value
  #
  # *Parameters*:
  # - <tt>$item</tt> {*} the item to generate a unique hash from
  # *Returns*:
  # - {String} a token of the string
  #
  def tokenize(item)
    prefix = helpers.to_str(environment.var('CONFIG_GENERATED_TAG_PREFIX') || 'archetype') + '-'
    token = prefix + helpers.to_str(item).hash.to_s
    return Sass::Script::Value::String.new(token)
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
    return Sass::Script::Value::String.new(content)
  end

  #
  # given a string of styles, convert it into a map
  #
  # *Parameters*:
  # - <tt>$string</tt> {String} the string to convert
  # *Returns*:
  # - <tt>$map</tt> {Map} the converted map of styles
  #
  ## TODO: this doesn't work yet...
  def _style_string_to_map(string = '')
    # convert to string and strip all comments
    string = helpers.to_str(string, ' ').gsub(/\/\*[^\*\/]*\*\//, '')
    # then split it on each rule
    tmp = string.split(';')
    styles = []
    # and for each rule break it into it's key-value pairs
    tmp.each do |rule|
      kvp = []
      rule.split(':').each do |str|
        kvp.push Sass::Script::Value::String.new(str)
      end
      styles.push Sass::Script::Value::List.new(kvp, :comma)
    end
    # the recompose the list
    return Sass::Script::Value::Map.new(styles)
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
