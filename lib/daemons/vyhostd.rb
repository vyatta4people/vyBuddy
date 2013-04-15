#!/usr/bin/ruby
#
# vyBuddy host daemon - monitors and queries host with specified <id>
#

# We load only needed stuff here, cause we care about memory consumption
require 'rubygems'
require 'active_record'
require 'action_mailer'
require 'tempfile'
require File.expand_path('../../../config/constants.rb', __FILE__)
require File.expand_path('../../../app/models/vyatta_host.rb', __FILE__)
require File.expand_path('../../../app/models/vyatta_host_state.rb', __FILE__)
require File.expand_path('../../../app/models/vyatta_host_group.rb', __FILE__)
require File.expand_path('../../../app/models/user.rb', __FILE__)
require File.expand_path('../../../app/models/ssh_key_pair.rb', __FILE__)
require File.expand_path('../../../app/models/task.rb', __FILE__)
require File.expand_path('../../../app/models/task_remote_command.rb', __FILE__)
require File.expand_path('../../../app/models/task_group.rb', __FILE__)
require File.expand_path('../../../app/models/task_vyatta_host_group.rb', __FILE__)
require File.expand_path('../../../app/models/remote_command.rb', __FILE__)
require File.expand_path('../../../app/models/filter.rb', __FILE__)
require File.expand_path('../../../app/models/display.rb', __FILE__)
require File.expand_path('../../../app/models/log.rb', __FILE__)
require File.expand_path('../../../app/models/setting.rb', __FILE__)
require File.expand_path('../../../app/mailers/user_mailer.rb', __FILE__)

if ARGV.length != 1 or !ARGV[0].match(/^[0-9]+$/) or ARGV[0].to_i <= 0
  warn "Usage: #{File.basename(__FILE__, '.rb')} <id>"
  warn "       <id> = 1..N"
  exit 1
end

ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.establish_connection(YAML.load_file(File.expand_path('../../../config/database.yml', __FILE__))[ENV['RAILS_ENV']])

vyatta_host_id = ARGV[0].to_i
begin
  vyatta_host  = VyattaHost.find(vyatta_host_id)
rescue => e
  warn e.message
  exit 2
end

vyatta_host.set_daemon_log_parameters

def graceful_shutdown
  Log.info("Daemon stopped")
  exit(0)
end
Signal.trap("TERM") { graceful_shutdown }
Signal.trap("INT")  { graceful_shutdown }

Log.info("Daemon started")

while true do
  # Yes, we need to "refresh" vyatta_host each loop step
  vyatta_host               = VyattaHost.find(vyatta_host_id)
  vyatta_host_state         = vyatta_host.vyatta_host_state
  vyatta_host.set_daemon_log_event_source # Event source i.e. daemon address may change at run-time

  # Try to establish SSH connection to Vyatta host
  vyatta_host_state_changed = false
  begin
    raise(vyatta_host.ssh_error) if !vyatta_host.check_reachability
  rescue => e
    Log.error("Could not reach Vyatta host: #{e.message}")
    vyatta_host_state_changed         = true if vyatta_host_state.is_reachable
    vyatta_host_state.is_reachable    = false
  else
    Log.info("Vyatta host become reachable") if !vyatta_host_state.is_reachable
    vyatta_host_state_changed         = true if !vyatta_host_state.is_reachable
    vyatta_host_state.is_reachable    = true
  ensure
    if vyatta_host.is_monitored and vyatta_host_state_changed
      notified_users = User.enabled.where(:receives_notifications => true)
      notified_users.each do |user|
        begin
          UserMailer.vyatta_host_state_change_notification(user, vyatta_host).deliver
        rescue => e
          Log.error("Could not send email notification to #{user.email}: #{e.inspect}")
        end
      end
    end
    begin
      vyatta_host_state.save!
    rescue => e
      Log.fatal("Unable to save Vyatta host state: #{e.message}")
    end
    if !vyatta_host_state.is_reachable
      sleep(vyatta_host.polling_interval)
      next
    end
  end
  sleep(GRACE_PERIOD)

  # Verify (and upload if needed) executors, check Vyatta software version and load average
  Log.error("Unable to verify #{vyatta_host.unmatched_modes.join(' and ')} mode executors") if !vyatta_host.verify_executors([:system, :operational], true)
  vyatta_host_state.vyatta_version = vyatta_host.get_vyatta_version
  vyatta_host_state.load_average   = vyatta_host.get_load_average
  vyatta_host_state.save
  sleep(GRACE_PERIOD)

  Log.error("Unable to verify configuration mode executor") if !vyatta_host.verify_executors([:configuration], true)

  vyatta_host.execute_tasks(:background) if !vyatta_host.is_passive

  sleep(vyatta_host.polling_interval)
end
