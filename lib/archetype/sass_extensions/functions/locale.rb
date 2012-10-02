#
# This module provides an interface for localization.
#
module Archetype::SassExtensions::Locale
  #
  # get the current locale specified in config
  #
  # *Returns*:
  # - {String} the current locale
  #
  def locale
    return Sass::Script::String.new(Compass.configuration.locale || 'en_US')
  end

  #
  # test a list of locales against the current locale (supports an alias map)
  #
  # *Parameters*:
  # - <tt>$locales</tt> {List} the list of locales to test
  # *Returns*:
  # - {Boolean} is the current locale in the list or not
  #
  def lang(locales)
    locales = locales.to_a.collect{|i| i.to_s}
    locales.each do |key|
      if a = locale_aliases[key]
        locales.delete(key)
        locales.concat(a)
      end
    end
    return Sass::Script::Bool.new(locales.include?(locale.to_s))
  end
  
  #
  # get the current reading direction
  #
  # *Returns*:
  # - {String} is the current reading direction [ltr|rtl]
  #
  def reading_direction
    direction = Compass.configuration.reading || 'ltr'
    return Sass::Script::String.new(direction == 'rlt' ? 'rtl' : 'ltr')
  end

private
  #
  # provides an alias mapping for locale names
  #
  # *Returns*:
  # - {Hash} a hash of aliases
  #
  # TODO - make this easily extensible
  def locale_aliases
    if @locale_aliases.nil?
      a = {}
      a['CJK'] = ['ja_JP', 'ko_KR', 'zh_TW', 'zh_CN']
      @locale_aliases = a
    end
    return @locale_aliases
  end
end
