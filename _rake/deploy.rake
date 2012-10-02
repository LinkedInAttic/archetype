task :deploy => :build do
  message = ENV['message'] || 'updating site'
  #sh "git add . && git commit -am \"#{message}\" && git push origin master"
end

task :build do
  Rake::Task["build:pages"].invoke
  Rake::Task["build:css"].invoke
end
namespace :build do
  task :pages do
    puts "building pages..."
    sh "jekyll > /dev/null 2>&1"
  end

  task :css do
    puts "generating CSS... "
    sh "compass clean -q assets/ && compass compile -q assets/"
  end
end
