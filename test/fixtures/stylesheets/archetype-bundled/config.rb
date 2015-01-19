require 'turn'
require 'true'

ext_name = File.basename(File.dirname(__FILE__))

# add extensions to import paths
extensions_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'extensions'))
extensions = Dir.entries(extensions_dir) - [ext_name, '.', '..']
extensions.each do |extension|
  lib_dir = File.join(extensions_dir, extension, 'lib')
  $:.unshift(lib_dir) unless $:.include?(lib_dir)
end

require File.expand_path(File.join(
  File.dirname(__FILE__), '..', '..', '..', '..',
  'extensions', ext_name,
  'lib', ext_name
))

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
