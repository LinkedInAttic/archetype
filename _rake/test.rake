desc "test cases"
task :test do
  Rake::Task["build:all"].invoke
end
