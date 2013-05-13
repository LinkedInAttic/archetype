## VERSIONING
desc "get the current working version of #{@spec.name}"
task :version do
  puts "local version v#{@spec.version}"
end

def bump(what)
  file = File.join(File.dirname(__FILE__), '..', 'VERSION.yml')
  f = File.read(file)
  @version = YAML::load(f)
  order = [:major, :minor, :build, :iteration]
  order.each{ |w| what = w if not @version[w].nil? } if what == :min
  @version[what] ||= 0
  @version[what] += 1
  # reset sub-versions
  slot = order.index(what) || order.size
  @version[:minor] = 0 if slot < order.index(:minor) and not @version[:minor].nil?
  @version[:build] = 0 if slot < order.index(:build)  and not @version[:build].nil?
  @version.delete(:state) if slot < order.index(:iteration)
  @version.delete(:iteration) if slot < order.index(:iteration)
  File.open(file, 'w+') {|f| f.write(YAML.dump(@version)) }
  version = "v#{@version[:major]}"
  version += ".#{@version[:minor]}" if @version[:minor]
  version += ".#{@version[:build]}" if @version[:build]
  version += ".#{@version[:state]}" if @version[:state]
  version += ".#{@version[:iteration]}" if @version[:iteration]
  version = version.colorize(:green)
  puts "bumped to #{version}"
end

namespace :version do
  desc "bump the minimum working version"
  task :bump do
    bump(:min)
  end

  namespace :bump do
    desc "bump major version"
    task :major do
      bump(:major)
    end

    desc "bump minor version"
    task :minor do
      bump(:minor)
    end

    desc "bump build version"
    task :build do
      bump(:build)
    end
  end
end
