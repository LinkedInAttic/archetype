require 'fileutils'

## BUIDLING and INSTALLING
namespace :gem do

  desc "build Archetype gems"
  task :build do
    FileUtils.rm_rf('pkg')
    with_each_gemspec do |file, spec|
      puts "build gem: #{file}"
      sh "gem build #{file}"
    end
    FileUtils.mkdir_p('pkg')
    FileUtils.mv(Dir['*.gem'], 'pkg')
  end

  desc "install Archetype gems locally"
  task :install => :build do
    apply_action_to_built_gems('gem install --no-ri --no-rdoc')
  end

  desc "uninstall Archetype gems locally"
  task :uninstall do
    # uninstalls each known gem
    with_each_gemspec do |file, spec|
      sh "#{ENV['SUDO']} gem uninstall #{spec.name} -x -a#{@devnull}"
    end
  end

  desc "reinstall Archetype gems locally"
  task :reinstall => [:uninstall, :install]
end

# executes a block with each discoverable gemspec
def with_each_gemspec
  Dir.glob("{,*,*/*}.gemspec").each do |file|
    yield(file, Gem::Specification.load(file)) if block_given?
  end
end

# applies an action to each built gem
def apply_action_to_built_gems(*actions)
  gems = Dir.glob('pkg/*.gem')
  actions.each do |action|
    gems.each do |name|
      sh "#{action} #{name}"
    end
  end
end
