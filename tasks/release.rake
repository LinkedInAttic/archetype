## RELEASE
desc "push new #{@spec.name} gem release and add a git tag"
task :release do
  version = @spec.version
  clean = `git status` =~ /nothing to commit \(working directory clean\)/
  puts "Before proceeding, all UNPUBLISHED changes will be reverted".colorize(:yellow) if not clean
  official = ENV['OFFICIAL']
  if official
    # strip off the revision if it's set
    version = @version_without_revision
    puts "You are about to release v#{version}. Is this correct? [y/n]".colorize(:cyan)
  else
    puts "You are about to release an UNOFFICIAL version #{version}. Proceed? [y/n]".colorize(:yellow)
  end
  if (($stdin.gets.chomp)[0] == 'y')
    Rake::Task['git:revert'].invoke if not clean
    Rake::Task['gem:build'].invoke
    sh "git tag -a v#{version} -m \"version #{version}\" && git push --tags" if official
    sh "gem push #{@spec.name}-#{version}.gem"
    puts "Successfully released v#{version}!".colorize(:green)
  else
    puts "Release aborted!".colorize(:red)
  end
end

namespace :release do
  desc "push an OFFICIAL #{@spec.name} gem release and add a git tag"
  task :official do
    ENV['OFFICIAL'] = '1'
    Rake::Task['release'].invoke
  end
end
