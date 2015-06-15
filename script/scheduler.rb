#!/usr/bin/env ruby

require 'fileutils'
require 'listen'

# Redefine system command
@original_system = method(:system)
define_method(:system) do |*args|
  @original_system.call(*args)
  exit 1 unless $?.exitstatus == 0
end

config_dir = ENV['BACKUP_CONFIG_DIR']

# Check for required parameters
if config_dir.nil? || config_dir == ''
  system "Missing required environment variable 'BACKUP_CONFIG_DIR'"
  exit 1
end

schedules_dir = "#{config_dir}/schedules"
schedule_cmd = '/usr/local/bin/create-schedule'

# Load from existing schedules
FileUtils.mkdir_p(schedules_dir)
puts "Loading existing schedules..."
Dir["#{schedules_dir}/*.rb"].each do |schedule_file|
  system(schedule_cmd, schedule_file)
end

puts "Watching for new schedules at '#{schedules_dir}'..."

# Create the listener loop for new log files in the specified directory
listener = Listen.to(schedules_dir, only: /.*\.rb$/, force_polling: true) do |_modified, added, _removed|
  # Handle new log files
  added.each do |schedule_file|
    Thread.new do
      puts "New schedule file '#{schedule_file}' detected."
      system(schedule_cmd, schedule_file)
    end
  end
end

# Start the listener loop and wait
listener.start
sleep
