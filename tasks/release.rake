## RELEASE
desc "push new #{@spec.name} gem release and add a git tag"
task :release do
  version = @spec.version
  clean = `git status --porcelain` == ''
  puts "Before proceeding, all UNPUBLISHED changes will be reverted".colorize(:yellow) if not clean
  # strip off the revision if it's set
  version = @version_without_revision
  puts "You are about to release #{"v#{version}".colorize(:green)}".colorize(:cyan)
  puts "Is this correct? [y/n]".colorize(:cyan)
  if (($stdin.gets.chomp)[0] == 'y')
    Rake::Task['git:revert'].invoke if not clean
    Rake::Task['gem:build'].invoke
    sh "git tag -a v#{version} -m \"version #{version}\" && git push --tags"
    sh "gem push #{@spec.name}-#{version}.gem"
    puts "Successfully released v#{version}!".colorize(:green)
  else
    puts "Release aborted!".colorize(:red)
  end
end
