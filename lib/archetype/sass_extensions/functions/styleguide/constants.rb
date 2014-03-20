module Archetype::SassExtensions::Styleguide

  private

  # :stopdoc:
  INHERIT     = 'inherit'
  STYLEGUIDE  = 'styleguide'
  DROP        = 'drop'
  DEFAULT     = 'default'
  REGEX       = 'regex'
  SPECIAL     = %w(states selectors)
  STATES      = SPECIAL[0]
  DROPALL     = %w(all true)
  MESSAGE_PREFIX = "[#{Archetype.name}:{origin}:{phase}] --- `"
  MESSAGE_SUFFIX = "` ---"
  # these are unique CSS keys that can be exploited to provide fallback functionality by providing a second value
  # e.g color: red; color: rgba(255,0,0, 0.8);
  FALLBACKS   = %w(background background-image background-color border border-bottom border-bottom-color border-color border-left border-left-color border-right border-right-color border-top border-top-color clip color layer-background-color outline outline-color white-space extend)
  # these are mixins that make sense to run multiple times within a block
  MULTIMIXINS = %w(target-browser)
  # NOTE: these are no longer used/needed if you're using the map structures
  ADDITIVES   = FALLBACKS + [DROP, INHERIT, STYLEGUIDE] + MULTIMIXINS
  @@archetype_styleguide_mutex = Mutex.new
  @@styleguide_themes ||= nil
  # :startdoc:

end
