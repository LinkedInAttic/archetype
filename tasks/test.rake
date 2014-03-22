## TESTS
require 'rake/testtask'

@test_opts = {
  :verbose => !ENV['CI']
}

task :test do
  unless ENV['UPDATING_TESTS']
    # make sure the gem is buildable
    puts "testing the gems build correctly..."
    Rake::Task['gem:build'].invoke
  end
end

Rake::TestTask.new :test do |t|
  t.libs << 'lib'
  t.libs << 'test'
  test_files = FileList['test/**/*_test.rb']
  t.test_files = test_files
  t.verbose = true
end

namespace :test do
  debug = false

  desc "only run the specified tests"
  task :only do
    tests = ARGV
    ENV['ARCHETYPE_TESTS'] = tests.join(',')
    Rake::Task['test'].invoke
    exit 0
  end

  desc "update test expectations if needed"
  task :update do
    ENV['UPDATING_TESTS'] = '1'
    Rake::Task['test:update:fixtures'].invoke
  end

  namespace :update do
    # paths
    EXPECTED  = 'expected'
    TMP       = 'tmp'
    FIXTURES  = '../test/fixtures/stylesheets/archetype'
    #desc "update fixture expectations for test cases if needed"
    task :fixtures do
      puts "checking test cases...\n"
      Rake::Task['test'].invoke
    end
  end
end
