## RELEASE

def proceed_on_input(message = nil)
  puts message if not message.nil?
  if not (($stdin.gets.chomp)[0] == 'y')
    puts "Release aborted!".colorize(:red)
    exit 1
  else
    yield if block_given?
  end
end

desc "push new Archetype gems release and add a git tag"
task :release do
  ENV['OFFICIAL'] = '1'
  version = Archetype::VERSION
  git_status = `git status --porcelain`
  clean = git_status == ''
  if not clean
    puts "Before releasing, all UNPUBLISHED changes will be reverted".colorize(:yellow)
    puts git_status
  end
  puts "#{'You are about to release'.colorize(:cyan)} #{"v#{version}".colorize(:green)}"
  proceed_on_input "Is this correct? [y/n]".colorize(:cyan) do
    Rake::Task['git:revert'].invoke if not clean
    Rake::Task['gem:build'].invoke
    begin
      puts "checking previously released versions..."
      versions = `gem list \^archetype\$ --remote --all --pre`
      if (/archetype.*(\(|\s)#{version.gsub(/\./, '\.')}(\,|\))/ =~ versions)
        proceed_on_input "It appears that v#{version} was already released. Are you sure you want to proceed? [y/n]".colorize(:yellow)
      end
    rescue
      proceed_on_input "couldn't verify release versions, proceed with caution".colorize(:yellow)
    end

    # add `upstream` remote (all release tags should go upstream)
    sh "git remote add upstream git@github.com:linkedin/archetype.git #{@devnull}"
    # tag the git repo
    sh "git tag -a v#{version} -m \"version #{version}\" && git push --tags upstream master"

    # push the gems
    apply_action_to_built_gems('gem push')

    puts "Successfully released v#{version}!".colorize(:green)
  end
end
