require 'turn'
require 'true'
require 'archetype'

# only use import-once locally, travis should reflect the non-ideal state where a user is not using compass-import-once
require 'compass/import-once/activate' unless ENV['CI']

project_type      = :stand_alone
css_dir           = "tmp"
sass_dir          = "source"
images_dir        = "assets/images"
fonts_dir         = "assets/fonts"
output_style      = :expanded
http_images_path  = "/assets/images"
http_fonts_path   = "/assets/fonts"
line_comments     = false
environment       = :production

# for testing purposes, make sure things work with aggressive caching turned on
memoize           = :aggressive

locale_aliases    = {
  'cyrillic' => ['ru_RU', 'az_AZ', 'sr_SP', 'uz_UZ']
}

asset_cache_buster :none

disable_warnings = true

# test meta values
meta = {
  'featureEnabled' => Sass::Script::Value::Bool.new(true),
  'somethingElse' => 'testing'
}
