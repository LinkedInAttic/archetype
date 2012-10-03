@assets_path = 'assets/themes/archetype/'
task :deploy => :build do
  message = ENV['message'] || 'updating site'
  puts "deploying to GitHub..."
  sh "git add . && git commit -am \"#{message}\" && git push origin gh-pages"
  puts "all done!"
end

task :build do
  Rake::Task["build:css"].invoke
end
namespace :build do
  task :css do
    puts "generating CSS... "
    sh "compass clean -q #{@assets_path} && compass compile -q #{@assets_path}"
  end
end
