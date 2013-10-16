## RELEASE
desc "push new #{@spec.name} gem release and add a git tag"

def proceed_on_input(message = nil)
  puts message if not message.nil?
  if not (($stdin.gets.chomp)[0] == 'y')
    puts "Release aborted!".colorize(:red)
    exit 1
  else
    yield if block_given?
  end
end

task :release do
  ENV['OFFICIAL'] = '1'
  version = @spec.version
  git_status = `git status --porcelain`
  clean = git_status == ''
  if not clean
    puts "Before releasing, all UNPUBLISHED changes will be reverted".colorize(:yellow)
    puts git_status
  end
  # strip off the revision if it's set
  version = @version_without_revision
  puts "You are about to release #{"v#{version}".colorize(:green)}".colorize(:cyan)
  proceed_on_input "Is this correct? [y/n]".colorize(:cyan) do
    #Rake::Task['git:revert'].invoke if not clean
    Rake::Task['gem:build'].invoke
    begin
      puts "checking previously released versions..."
      versions = `gem list \^archetype\$ --remote --all --pre`
      pattern = /archetype.*(\(|\s)#{version.gsub(/\./, '\.')}(\,|\))/
      if (/archetype.*(\(|\s)#{version.gsub(/\./, '\.')}(\,|\))/ =~ versions)
        proceed_on_input "It appears that v#{version} was already released. Are you sure you want to proceed? [y/n]".colorize(:yellow)
      end
    rescue
      proceed_on_input "couldn't verify release versions, proceed with caution".colorize(:yellow)
    end

    #%x{
    #  git tag -a v#{version} -m \"version #{version}\" && git push --tags
    #  gem push #{@spec.name}-#{version}.gem
    #}
    puts "Successfully released v#{version}!".colorize(:green)
  end
end
