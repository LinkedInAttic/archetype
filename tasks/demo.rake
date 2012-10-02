## DEMO
desc "build #{@spec.name} and create a Compass demo"
task :demo do
  Rake::Task['gem:reinstall'].invoke
  sh "compass create ./demo/ -r archetype --using archetype/example --force -x scss"
  puts "demo successfully created. see demo/index.html".colorize(:green)
end
