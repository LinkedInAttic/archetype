require 'turn'
require 'true'

require File.expand_path(File.join(
  File.dirname(__FILE__), '..', '..', '..', '..',
  'extensions', File.basename(File.dirname(__FILE__)),
  'lib', File.basename(File.dirname(__FILE__)))
)

# only use import-once locally, travis should reflect the non-ideal state where a user is not using compass-import-once
require 'compass/import-once/activate' unless ENV['CI']

asset_cache_buster :none

disable_warnings  = true
line_comments     = false
project_type      = :stand_alone
output_style      = :expanded
environment       = :production

assets_dir        = 'assets'
css_dir           = 'tmp'
sass_dir          = 'source'
images_dir        = "#{assets_dir}/images"
fonts_dir         = "#{assets_dir}/fonts"
http_images_path  = "/#{assets_dir}/images"
http_fonts_path   = "/#{assets_dir}/fonts"

# for testing purposes, make sure things work with aggressive caching turned on
memoize           = :aggressive

locale_aliases    = {
  'cyrillic' => ['ru_RU', 'az_AZ', 'sr_SP', 'uz_UZ']
}


# test meta values
archetype_meta = {
  'featureEnabled' => Sass::Script::Value::Bool.new(true),
  'somethingElse' => 'testing'
}