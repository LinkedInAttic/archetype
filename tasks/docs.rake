## DOCS
unless ENV["CI"]
  desc "generate API documentation"
  task :docs do
    Rake::Task['rdoc'].invoke
    %x[mkdir -p #{@docs}/sassdoc/ && sassdoc stylesheets/ --stdout > #{@docs}/sassdoc/sassdoc.json]
    puts "Documentation created at #{@docs}".colorize(:green)
  end
  require 'rdoc/task'
  RDoc::Task.new do |rdoc|
    rdoc.rdoc_dir = "#{@docs}/rdoc"
    rdoc.title = "Archetype v#{Archetype::VERSION} Documentation"
    rdoc.rdoc_files.include('lib/README.rdoc', 'lib/**/*.rb')
    rdoc.rdoc_files.exclude('lib/**/functions.rb', 'lib/**/sass_extensions.rb') # exclude harness files
    rdoc.options << "--quiet"
    rdoc.main = "lib/README.rdoc"
  end
end
