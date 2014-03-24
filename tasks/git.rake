## GIT
namespace :git do
  desc "cleanup working directory"
  task :clean do
    sh "git", "clean", "-fdx"
  end

  desc "revert all current changes"
  task :revert => :clean do
    sh "git checkout ."
  end

  desc "add a tag to git"
  task :tag, :tg, :msg do |t, args|
    tag = args[:tg]
    if tag.nil? or tag.empty?
      puts "you must specify a tag. e.g. `rake #{t}[\"this is my tag\"]`".colorize(:red)
    else
      msg = " -m \"#{args[:msg]}\"" if args[:msg]
      sh "git tag -a \"#{tag}\"#{msg} && git push --tags origin master"
    end
  end
end
