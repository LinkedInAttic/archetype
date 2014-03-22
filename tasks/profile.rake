## PROFILE
# NOTE: this requires `ghostscript` and `graphviz` installed to see the visual report (pdf)
#  brew install ghostscript && brew install graphviz
desc "profile Archetype and generate the reports"
task :profile do
  ENV['ARCHETYPE_PROFILER'] = "archetype__#{RUBY_VERSION}__#{Archetype::VERSION}__#{Time.now.to_i}"
  puts "running test cases with profiler..."
  Rake::Task['test'].invoke
  puts "\n\n#{'-'*20}\n\n"
  puts "analyzing profile results..."
  file = ENV['ARCHETYPE_PROFILER']
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
  # copy over the gc file
  file = "/tmp/#{file}.gc"
  if File.exist?(file)
    FileUtils.cp(file, "#{output}.gc")
    puts " see results in #{output.sub(output_base, '.')}.gc"
  end
end
