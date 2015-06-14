#!/usr/bin/env ruby

require 'fileutils'

# Set schedule config
schedule_config = ENV['SCHEDULE_CONFIG'] || ARGV[0]

# Check for required parameters
if schedule_config.nil? || schedule_config == ''
  system "Missing required environment variable 'SCHEDULE_CONFIG'"
  exit 1
end
unless File.exist?(schedule_config)
  system "Could not find schedule configuration '#{schedule_config}'"
  exit 1
end

# Set the cron file
cron_file = File.join('/etc/cron.d', File.basename(schedule_config, File.extname(schedule_config)))

# Write the whenever schedule to the cron definition
puts "Creating cronfile '#{cron_file}' from schedule '#{schedule_config}'... "
cron_schedule = `whenever --load-file '#{schedule_config}'`
File.open(cron_file, 'w') { |f| f.write(cron_schedule) }
