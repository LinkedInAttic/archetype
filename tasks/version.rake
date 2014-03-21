## VERSIONING
desc "get the current working version of #{@spec.name}"
task :version do
  puts "local version v#{@spec.version}"
end

