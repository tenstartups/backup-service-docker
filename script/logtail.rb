#!/usr/bin/env ruby

require 'listen'

# Extract arguments
log_directory = ENV['LOG_DIRECTORY'] || ARGV[0]
log_pattern = ENV['LOG_PATTERN'] || ARGV[1] || '\\.log'

# Check for required parameters
if log_directory.nil? || log_directory == ''
  system "Missing required environment variable 'LOG_DIRECTORY'"
  exit 1
end

puts "Watching for logs at '#{log_directory}' matching '#{log_pattern}' regular expression pattern..."

# Create the listener loop for new log files in the specified directory
listener = Listen.to(log_directory, only: /#{log_pattern}/, force_polling: true) do |_modified, added, _removed|
  # Handle new log files
  added.each do |logfile|
    Thread.new do
      puts "New log file '#{logfile}' detected."
      # Tail and echo new log files as they appear until they are deleted
      IO.popen("tail -f '#{logfile}'").each_line do |line|
        puts "[#{File.basename(logfile, File.extname(logfile))}] #{line}"
      end
      puts "Log file '#{logfile}' closed."
    end
  end
end

# Start the listener loop and wait
listener.start
sleep
