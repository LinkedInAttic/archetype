## PROFILE
desc "profile #{@spec.name} and generate the reports"
task :profile do
  ENV['ARCHETYPE_PROFILER'] = '1'
  puts "running test cases with profiler..."
  Rake::Task['test'].invoke
  puts "analyzing profile results..."
  file = "artchetype__#{RUBY_VERSION}__#{@spec.version}"
  input = "/tmp/#{file}.perf"
  output_base = File.join(File.dirname(__FILE__), '..')
  output = File.join(output_base, 'tmp', 'profiles')
  FileUtils.mkdir_p output
  output = File.join(output, file)
  FORMATS = {
    :text => 'txt',
    :pdf  => 'pdf'
  }.each do |format, ext|
    %x[pprof.rb --#{format.to_s} #{input} > #{output}.#{ext}]
    puts " see results in #{output.sub(output_base, '.')}.#{ext}"
  end
end
