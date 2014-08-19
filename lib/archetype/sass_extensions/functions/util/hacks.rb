module Archetype::SassExtensions::Util::Hacks

  #
  # parse a CSS content string and format it for injection into innerText
  #
  # *Parameters*:
  # - <tt>$content</tt> {String} the CSS content string
  # *Returns*:
  # - {String} the processed string
  #
  def _ie_pseudo_content(content)
    content = helpers.to_str(content)
    # convert char codes (e.g. `\2079` -> `\u2079`)
    content.gsub!(/\\([\da-fA-F]{4})\s?/, ['\1'.hex].pack('U*'))
    # cleanup quotes
    content.gsub!(/\A"|"\Z/, '').gsub!(/\"/, '\\"')
    return identifier(content)
  end

  #
  # given a string of styles, convert it into a map
  #
  # *Parameters*:
  # - <tt>$string</tt> {String} the string to convert
  # *Returns*:
  # - {Map} the converted map of styles
  #
  def _style_string_to_map(string = '')
    # convert to string and strip all comments
    string = helpers.to_str(string, ' ').gsub(/\/\*(?!\*\/)*\*\//, '')
    # then split it on each rule and for each rule break it into it's key-value pairs
    styles = string.split(';').map do |rule|
      k, v = rule.split(':')
      [identifier(k), identifier(v)]
    end
    # then recompose the map
    return Sass::Script::Value::Map.new(Sass::Util.to_hash(styles))
  end

end
