module Archetype::SassExtensions::Util::Images

  #
  # helper to determine if a sprite is already set or sprites are disabled
  #
  # *Parameters*:
  # - <tt>$sprite</tt> {SpriteMap} the sprite map to check against
  # *Returns*:
  # - {Boolean} should the sprite be set
  #
  def _shouldSetSprite(sprite)
    is_sprite = sprite.is_a?(Compass::SassExtensions::Sprites::SpriteMap)
    should_set_sprite = !global_sprites_disabled? && !is_sprite
    return bool(should_set_sprite)
  end
  Sass::Script::Functions.declare :get_collection, [:components, :min]

  #
  # check that a sprite isn't null or false
  #
  # *Parameters*:
  # - <tt>$map</tt> {SpriteMap} the sprite map to check against
  # *Returns*:
  # - {Boolean} is the sprite set
  #
  def _archetype_check_sprite(map)
    status = !(global_sprites_disabled? && (is_null(map) || !map.value))
    return bool(status)
  end
  Sass::Script::Functions.declare :_archetype_check_sprite, [:map]

  #
  # wrapper for `sprite`
  #
  # *Parameters*:
  # - <tt>$map</tt> {SpriteMap} the sprite map
  # - <tt>$sprite</tt> {Sprite} the sprite name
  # - <tt>$offset-x</tt> {Number} the horizontal offset of the sprite position
  # - <tt>$offset-y</tt> {Number} the vertical offset of the sprite position
  # *Returns*:
  # - {Sprite} the sprite object or `null`
  #
  def _archetype_sprite(map, sprite, offset_x = number(0), offset_y = number(0))
    return null unless _archetype_check_sprite(map)
    return sprite(map, sprite, offset_x, offset_y)
  end
  Sass::Script::Functions.declare :_archetype_sprite, [:map, :sprite, :offset_x, :offset_y]

  #
  # wrapper for `sprite-position`
  #
  # *Parameters*:
  # - <tt>$map</tt> {SpriteMap} the sprite map
  # - <tt>$sprite</tt> {Sprite} the sprite name
  # - <tt>$offset-x</tt> {Number} the horizontal offset of the sprite position
  # - <tt>$offset-y</tt> {Number} the vertical offset of the sprite position
  # *Returns*:
  # - {List} the sprite position or `null`
  #
  def _archetype_sprite_position(map, sprite, offset_x = number(0), offset_y = number(0))
    return null unless _archetype_check_sprite(map)
    return sprite_position(map, sprite, offset_x, offset_y)
  end
  Sass::Script::Functions.declare :_archetype_sprite_position, [:map, :sprite, :offset_x, :offset_y]

  #
  # wrapper for `sprite-url`
  #
  # *Parameters*:
  # - <tt>$map</tt> {SpriteMap} the sprite map
  # *Returns*:
  # - {String} the sprite URL or `null`
  #
  def _archetype_sprite_url(map)
    return null unless _archetype_check_sprite(map)
    return sprite_url(map)
  end
  Sass::Script::Functions.declare :_archetype_sprite_url, [:map]

  #
  # wrapper for `sprite-file`
  #
  # *Parameters*:
  # - <tt>$map</tt> {SpriteMap} the sprite map
  # - <tt>$sprite</tt> {Sprite} the sprite name
  # *Returns*:
  # - {ImageFile} the image or `null`
  #
  def _archetype_sprite_file(map, sprite)
    return null unless _archetype_check_sprite(map)
    return sprite_file(map, sprite)
  end
  Sass::Script::Functions.declare :_archetype_sprite_file, [:map, :sprite]

  #
  # wrapper for `image-width`
  #
  # *Parameters*:
  # - <tt>$image</tt> {ImageFile} the image
  # - <tt>$sprite</tt> {Sprite} the sprite name
  # *Returns*:
  # - {Number} the width of the image or `null`
  #
  def _archetype_image_width(image)
    return null if is_null(image).value
    return image_width(image)
  end
  Sass::Script::Functions.declare :_archetype_image_width, [:image]

  #
  # wrapper for `image-height`
  #
  # *Parameters*:
  # - <tt>$image</tt> {ImageFile} the image
  # - <tt>$sprite</tt> {Sprite} the sprite name
  # *Returns*:
  # - {Number} the height of the image or `null`
  #
  def _archetype_image_height(image)
    return null if is_null(image).value
    return image_height(image)
  end
  Sass::Script::Functions.declare :_archetype_image_height, [:image]

private

  def global_sprites_disabled?
    sprites_disabled = environment.var('CONFIG_DISABLE_STYLEGUIDE_SPRITES')
    return sprites_disabled.respond_to?(:value) ? sprites_disabled.value : false
  end

end