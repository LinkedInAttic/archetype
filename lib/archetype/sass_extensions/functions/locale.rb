#
# This module provides an interface for localization.
#
module Archetype::SassExtensions::Locale
  #
  # get the current locale specified in config or test a list of locales against the current locale
  #
  # *Parameters*:
  # - <tt>$locales</tt> {List} the list of locales to test
  # *Returns*:
  # - {String|Boolean} the current locale or whether or not the current locale is in the test set
  #
  def locale(locales = nil)
    locale = (environment.var('CONFIG_LOCALE') || Compass.configuration.locale || 'en_US').to_s
    # if the locales are nil, just return the current locale
    return Sass::Script::String.new(locale) if locales.nil?
    locales = locales.to_a.collect{|i| i.to_s}
    # add wild card support for language or territory
    match = locale.match(LOCALE_PATTERN)
    # language with wildcard territory
    language = match[1] + '_'
    # territory with wildcard language
    territory = '_' + match[2]
    # for each item, look it up in the alias list
    locales.each do |key|
      if a = locale_aliases[key]
        locales.delete(key)
        locales.concat(a)
      end
    end
    return Sass::Script::Bool.new(locales.include?(locale) || locales.include?(language) || locales.include?(territory))
  end

  #
  # test a list of locales against the current locale (this is now just an alias for locales(), for back-compat)
  #
  # *Parameters*:
  # - <tt>$locales</tt> {List} the list of locales to test
  # *Returns*:
  # - {Boolean} is the current locale in the list or not
  #
  def lang(locales)
    return locale(locales)
  end

  #
  # get the current reading direction
  #
  # *Returns*:
  # - {String} is the current reading direction [ltr|rtl]
  #
  def reading_direction
    direction = Compass.configuration.reading || 'ltr'
    return Sass::Script::String.new(direction == 'rtl' ? 'rtl' : 'ltr')
  end

private

  LOCALE_PATTERN = /([a-z]{2})[-_]?([a-z]{2}?)/i

  #
  # provides an alias mapping for locale names
  #
  # *Returns*:
  # - {Hash} a hash of aliases
  #
  # TODO - make this easily extensible
  def locale_aliases
    if @locale_aliases.nil?
      a = {
        'CJK' => ['ja_JP', 'ko_KR', 'zh_TW', 'zh_CN']
      }
      @locale_aliases = a
    end
    return @locale_aliases
  end
end
