## DEMO
desc "build Archetype and create a Compass demo"
task :demo do
  Rake::Task['gem:install'].invoke
  sh "compass clean && compass create ./demo/ -r archetype --quiet --force --using archetype/example -x scss"
  puts "demo successfully created. see demo/index.html".colorize(:green)
end
