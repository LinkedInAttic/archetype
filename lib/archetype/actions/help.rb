description = "Get help on an Archetype action"
if @description.nil?
  # do stuff...
  @help = true

  if not ARGV[1].nil? and ARGV[1] != 'help'
    action = File.join(@actions_path, ARGV[1])
    begin
      load "#{action}.rb"
    rescue
      puts "unknown action: #{ARGV[1]}"
    end
  end
else
  @description = description
end
