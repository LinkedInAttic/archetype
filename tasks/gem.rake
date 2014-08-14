require 'fileutils'

@dist_dir = File.expand_path('dist')

## BUILDING and INSTALLING
namespace :gem do

  desc "build Archetype gems"
  task :build do
    if RUBY_VERSION < '1.9'
      puts "Archetype requires Ruby 1.9 or higher to build the gems"
      puts "Please upgrade your version of Ruby (#{RUBY_VERSION})"
      puts "Check out #{'https://rvm.io/'.colorize(:cyan)} for details"
      puts "Aborting...".colorize(:red)
      exit 1
    end
    root_dir = File.expand_path('.')
    defaults = %w(LICENSE VERSION)
    # cleanup the dist directory
    FileUtils.rm_rf(@dist_dir)
    FileUtils.mkdir_p(@dist_dir)
    with_each_gemspec do |file, spec|
      remove_after = []
      build_path = File.dirname(file)
      # copy over any missing files
      defaults.each do |file|
        unless File.exist?(File.join(build_path, file))
          remove_after << file
          FileUtils.cp(File.join(root_dir, file), File.join(build_path, file))
        end
      end
      # cd into the build directory and build the gem
      puts "\nbuilding #{File.basename(file, '.gemspec').colorize(:cyan)} gem..."
      sh "cd #{build_path} && gem build #{File.basename(file)}"

      # remove any files that were copied over
      remove_after.each do |file|
        FileUtils.rm_f(File.join(build_path, file))
      end
      # move the build gem into the dist directory
      FileUtils.mv(Dir[File.join(build_path, '*.gem')], @dist_dir)
    end
  end

  desc "install Archetype gems locally"
  task :install => :build do
    apply_action_to_built_gems('gem install --no-ri --no-rdoc')
  end

  desc "uninstall Archetype gems locally"
  task :uninstall do
    # uninstalls each known gem
    with_each_gemspec do |file, spec|
      begin
        sh "#{ENV['SUDO']} gem uninstall #{spec.name} -x -a#{@devnull}"
      rescue
        puts "could not uninstall #{spec.name}".colorize(:yellow)
      end
    end
  end

  desc "reinstall Archetype gems locally"
  task :reinstall => [:uninstall, :install]
end

# executes a block with each discoverable gemspec
def with_each_gemspec
  Dir["**/*.gemspec"].each do |file|
    yield(file, Gem::Specification.load(file)) if block_given?
  end
end

# applies an action to each built gem
def apply_action_to_built_gems(*actions)
  gems = Dir[File.join(@dist_dir, '*.gem')]
  actions.each do |action|
    gems.each do |name|
      sh "#{action} #{name}"
    end
  end
end
