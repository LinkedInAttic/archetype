require "rubygems"
require 'rake'
require 'yaml'
require 'time'

SOURCE = "."
CONFIG = {
  'version'   => "0.2.13",
  'themes'    => File.join(SOURCE, "_includes", "themes"),
  'layouts'   => File.join(SOURCE, "_layouts"),
  'posts'     => File.join(SOURCE, "_posts"),
  'post_ext'  => "md",
  'theme_package_version' => "0.1.0"
}

#Load custom rake scripts
Dir['_rake/*.rake'].each { |r| load r }
