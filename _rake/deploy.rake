@assets_path = 'assets/'
desc "Deploy to GitHub"
task :deploy => :build do
  message = ENV['message'] || 'updating site'
  puts "deploying to GitHub..."
  sh "git add . && git commit -am \"#{message}\" && git push origin gh-pages"
  puts "all done!"
end

desc "Build asset packages"
task :build do
  Rake::Task["build:assets"].invoke
end
namespace :build do
  task :css do
    puts "generating CSS... "
    sh "compass clean -q #{@assets_path} && compass compile -q #{@assets_path}"
  end
  task :js do
    puts "bundling JavaScript..."
    sh "jammit -o assets/scripts/ -c assets/_assets.yml"
  end
  task :jekyll do
    puts "compiling jekyll files..."
    sh "jekyll build --safe"
  end
  task :assets do
    Rake::Task["build:css"].invoke
    Rake::Task["build:js"].invoke
  end
  task :all do
    Rake::Task["build:css"].invoke
    Rake::Task["build:js"].invoke
    Rake::Task["build:jekyll"].invoke
  end
end
