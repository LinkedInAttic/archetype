## BUIDLING and INSTALLING
namespace :gem do
  desc "build #{@spec.name} gem file"
  task :build do
    sh "gem build #{@gemspec}"
  end

  desc "install #{@spec.name} locally"
  task :install => :build do
    sh "#{ENV['SUDO']} gem install #{@spec.name}-#{@spec.version}.gem --no-ri --no-rdoc"
  end

  desc "uninstall #{@spec.name} locally"
  task :uninstall => :build do
    # uninstall and swallow errors
    to_devnull = " 2> #{@devnull}" if File.exist? @devnull
    sh "#{ENV['SUDO']} gem uninstall #{@spec.name} -x -a#{to_devnull}"
  end

  desc "reinstall #{@spec.name} locally"
  task :reinstall => [:uninstall, :install]
end
