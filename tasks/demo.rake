## DEMO
desc "build #{@spec.name} and create a Compass demo"
task :demo do
  Rake::Task['gem:reinstall'].invoke
  sh "compass clean && compass create ./demo/ -r archetype --quiet --using archetype/example -x scss"
  puts "demo successfully created. see demo/index.html".colorize(:green)
end
