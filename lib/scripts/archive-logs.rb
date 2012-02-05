#!/usr/bin/ruby
#
# Archive vyBuddy logs: back up and delete old ones.
#

require File.expand_path('../../../config/environment', __FILE__)

log_count = Log.count
if log_count <= KEEP_LOG_RECORDS
  puts "Nothing to do, only #{log_count.to_s} log records found."
  exit(0)
end

log_archive_limit = log_count - KEEP_LOG_RECORDS
logs_to_archive   = Log.find(:all, :limit => log_archive_limit)

data = Array.new
logs_to_archive.each do |log|
  data << log.as_text
end

if ENV['RAILS_ENV'] == 'production'
  log_backup_file = "#{LOG_BACKUP_DIR}/logs_#{Time.now.strftime("%Y%m%d%H%M%S")}.txt"
  f = File.new(log_backup_file, "w")
  f.write(data.join("\n"))
  f.close
  system("gzip #{log_backup_file}")
end

ActiveRecord::Base.connection.execute("DELETE FROM `logs` LIMIT #{log_archive_limit};")
ActiveRecord::Base.connection.execute("OPTIMIZE TABLE `logs`;")

puts("Archived #{log_archive_limit.to_s} log records.")
exit(0)
