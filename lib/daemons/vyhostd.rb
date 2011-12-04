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

while true do
  # Yes, we need to "refresh" vyatta_host each loop step
  vyatta_host           = VyattaHost.find(vyatta_host_id)
  vyatta_host_state     = vyatta_host.vyatta_host_state

  # Try to establish SSH connection to Vyatta host and check Vyatta software version and load average
  version_check         = RemoteCommand.find_or_create_by_command("show version | grep 'Version' | sed 's/.*: *//'", :mode => "operational")
  load_average          = RemoteCommand.find_or_create_by_command("uptime | sed 's/.*, //'", :mode => "system")
  begin
    version_check_result = vyatta_host.execute_remote_command(version_check)
    load_average_result  = vyatta_host.execute_remote_command(load_average)
  rescue => e
    warn "Could not reach Vyatta host (ID #{vyatta_host.id.to_s}): #{e.message}"
    vyatta_host_state.is_reachable    = false
  else
    vyatta_host_state.is_reachable    = true
    vyatta_host_state.vyatta_version  = version_check_result[:data]
    vyatta_host_state.load_average    = load_average_result[:data].to_f
  ensure
    vyatta_host_state.save
    if !vyatta_host_state.is_reachable
      next
    end
  end

  tasks = Task.where(:is_enabled => true)
  tasks.each do |task|
    task.task_remote_commands.each do |trc|
      remote_command  = trc.remote_command
      filter          = trc.filter
      display         = Display.find_or_create_by_vyatta_host_id(vyatta_host.id, :task_remote_command_id => trc.id)
      begin
        remote_command_result = vyatta_host.execute_remote_command(remote_command)
      rescue => e
        warn "Could not execute task \"#{remote_command.command}\" (Vyatta host ID #{vyatta_host.id.to_s}): #{e.message}"
        display.information = "Failed to retrieve information... (#{e.message})"
      else
        display.information = filter.apply([remote_command_result])
      ensure
        display.save
      end
    end
  end

  sleep 60
end