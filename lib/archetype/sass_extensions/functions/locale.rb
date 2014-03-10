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
    locale = get_locale(locale)
    # if the locales are nil, just return the current locale
    return identifier(locale) if locales.nil?
    locales = locales.to_a.collect{|i| i.to_s}
    # normalize the pieces of the locale
    locale = normalize_locale(locale)
    # for each item, look it up in the alias list
    locales.each do |key|
      if a = locale_aliases[key]
        locales.delete(key)
        locales.concat(a)
      end
    end
    return Sass::Script::Bool.new(
      locales.include?(locale) ||
      locales.include?("#{locale[:language]}_#{locale[:territory]}") ||
      locales.include?(locale[:language] + '_') ||
      locales.include?('_' + locale[:territory])
    )
  end
  alias_method :lang, :locale

  #
  # returns the locale language code
  #
  # *Parameters*:
  # - <tt>$locale</tt> {String} the locale to examine
  # *Returns*:
  # - {String|Null} the language code within the locale string
  #
  def locale_language(locale = nil)
    return get_locale_piece(locale, :language)
  end

  #
  # returns the locale territory code
  #
  # *Parameters*:
  # - <tt>$locale</tt> {String} the locale to examine
  # *Returns*:
  # - {String|Null} the territory code within the locale string
  #
  def locale_territory(locale = nil)
    return get_locale_piece(locale, :territory)
  end
  alias_method :locale_country, :locale_territory

  #
  # returns the locale modifier
  #
  # *Parameters*:
  # - <tt>$locale</tt> {String} the locale to examine
  # *Returns*:
  # - {String|Null} the modifier code within the locale string
  #
  def locale_modifier(locale = nil)
    return get_locale_piece(locale, :modifier)
  end

  #
  # get the current reading direction
  #
  # *Returns*:
  # - {String} is the current reading direction [ltr|rtl]
  #
  def reading_direction
    direction = Compass.configuration.reading || 'ltr'
    return identifier(direction == 'rtl' ? 'rtl' : 'ltr')
  end

private

  # pieces of the locale code
  #  (1) language
  #  (2) territory
  #  (3) encoding (not currently used)
  #  (4) modifier (e.g. @Cyrillic)
  LOCALE_PATTERN = /\"?([a-z]{2})?[-_]?([a-z]{2})?(\.[^@]*)?(?:\@([^\"]+))?\"?/i

  #
  # normalizes the locale string into an object
  #
  # *Parameters*:
  # - <tt>locale</tt> {String} the locale to normalize
  # *Returns*:
  # - {Hash} the normalized locale object
  #
  def normalize_locale(locale = nil)
    match = get_locale(locale).match(LOCALE_PATTERN) || []
    return {
      :language   => match[1].nil? ? nil : match[1].downcase,
      :territory  => match[2].nil? ? nil : match[2].upcase,
      :encoding   => match[3],
      :modifier   => match[4]
    }
  end

  #
  # get the locale from the given input
  # if nil, will use either the current global locale in $CONFIG_LOCALE or the locale set on the compiler
  #
  # *Parameters*:
  # - <tt>locale</tt> {Sass::String} the locale to use
  # *Returns*:
  # - {String} the locale string
  #
  def get_locale(locale = nil)
    return (locale || environment.var('CONFIG_LOCALE') || Compass.configuration.locale || 'en_US').to_s
  end

  #
  # returns a normalized piece of the locale
  #
  # *Parameters*:
  # - <tt>locale</tt> {String} the locale to examine
  # - <tt>piece</tt> {Symbol} the piece of the locale to extract
  # *Returns*:
  # - {Sass::String} a string of the locale piece requested
  #
  def get_locale_piece(locale = nil, piece = :language)
    piece = normalize_locale(locale)[piece]
    if piece.nil?
      return null
    else
      return identifier(piece)
    end
  end

  #
  # provides an alias mapping for locale names
  #
  # *Returns*:
  # - {Hash} a hash of aliases
  #
  def locale_aliases
    @locale_aliases ||= {
      'CJK' => ['ja_JP', 'ko_KR', 'zh_TW', 'zh_CN']
    }.merge(Compass.configuration.locale_aliases || {})
  end
end
