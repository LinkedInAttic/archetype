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

    # add `upstream` remote (all release tags should go upstream)
    begin
      %x[git ls-remote upstream #{@devnull}]
    rescue
      %x[git remote add upstream git@github.com:linkedin/archetype.git #{@devnull}]
    end

    # tag the git repo
    begin
      sh "git tag -a v#{version} -m \"version #{version}\""
      sh "git push --tags upstream master"
    rescue
      puts "manually verify the release was tagged properly on GitHub".colorize(:yellow)
    end

    # push the gems
    apply_action_to_built_gems('gem push')

    puts "Successfully released v#{version}!".colorize(:green)
  end
end
