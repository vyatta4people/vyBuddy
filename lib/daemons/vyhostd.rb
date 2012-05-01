#!/usr/bin/ruby
#
# vyBuddy host daemon - monitors and queries host with specified <id>
#

require File.expand_path('../../../config/environment', __FILE__)

if ARGV.length != 1 or !ARGV[0].match(/^[0-9]+$/) or ARGV[0].to_i <= 0
  warn "Usage: #{File.basename(__FILE__, '.rb')} <id>"
  warn "       <id> = 1..N"
  exit 1
end

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
  vyatta_host           = VyattaHost.find(vyatta_host_id)
  vyatta_host_state     = vyatta_host.vyatta_host_state
  vyatta_host.set_daemon_log_event_source # Event source i.e. daemon address may change at run-time

  # Try to establish SSH connection to Vyatta host
  begin
    raise(vyatta_host.ssh_error) if !vyatta_host.execute_command_via_ssh!("/bin/true")
  rescue => e
    Log.error("Could not reach Vyatta host: #{e.message}")
    vyatta_host_state.is_reachable   = false
  else
    Log.info("Vyatta host become reachable") if !vyatta_host_state.is_reachable
    vyatta_host_state.is_reachable   = true
  ensure
    begin
      vyatta_host_state.save!
    rescue => e
      Log.fatal("Unable to save Vyatta host state: #{e.message}")
    end
    if !vyatta_host_state.is_reachable
      sleep(UNREACHABLE_HOST_SLEEP_TIME)
      next
    end
  end
  sleep(GRACE_PERIOD)

  # Verify (and upload if needed) executors, check Vyatta software version and load average
  Log.error("Unable to verify #{vyatta_host.unmatched_modes.join(' and ')} mode executors") if !vyatta_host.verify_executors([:system, :operational], true)
  vyatta_host_state.vyatta_version = vyatta_host.execute_remote_command!("show version | grep 'Version' | sed 's/.*: *//'").strip
  vyatta_host_state.load_average   = vyatta_host.execute_remote_command!({:mode => :system, :command => "uptime | sed 's/.*, //'"}).strip.to_f
  sleep(GRACE_PERIOD)

  Log.error("Unable to verify configuration mode executor") if !vyatta_host.verify_executors([:configuration], true)
  task_groups = TaskGroup.enabled
  task_groups.each do |task_group|
    task_group.tasks(true).enabled.each do |task|
      task_remote_commands  = task.task_remote_commands(true)
      command_result_sets   = vyatta_host.execute_remote_commands(task_remote_commands.collect{ |trc| trc.remote_command })

      ci = 0
      task_remote_commands.each do |trc|
        remote_command  = trc.remote_command
        filter          = trc.filter

        display         = Display.find(:first, :conditions => { :vyatta_host_id => vyatta_host.id, :task_remote_command_id => trc.id })
        if !display
          display       = Display.create(:vyatta_host_id => vyatta_host.id, :task_remote_command_id => trc.id)
        end

        display.information = filter.apply(command_result_sets[ci][:stdout])
        display.save

        ci += 1
      end
    end
  end

  sleep(HOST_POLLING_INTERVAL)
end
