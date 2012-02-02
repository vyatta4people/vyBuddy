#!/usr/bin/ruby
#
# vyBuddy master daemon - starts and stops vyhostd processes
#

require File.expand_path('../../../config/environment', __FILE__)

Log.application  = :vymasterd
Log.event_source = "localhost"

def graceful_shutdown
  vyatta_hosts = VyattaHost.all
  vyatta_hosts.each do |vyatta_host|
    if vyatta_host.vyatta_host_state.is_daemon_running
      vyatta_host.stop_daemon
    end
    if vyatta_host.daemon_running?
      vyatta_host.kill_all_daemons
    end
  end
  exit(0)
end

Signal.trap("TERM") { graceful_shutdown }
Signal.trap("INT")  { graceful_shutdown }

Log.info("Daemon started")

rescue_chance_used = false
begin
  while true do
    enabled_vyatta_hosts = VyattaHost.where(:is_enabled => true)
    enabled_vyatta_hosts.each do |vyatta_host|
      if !vyatta_host.vyatta_host_state.is_daemon_running or !vyatta_host.daemon_running?
        vyatta_host.start_daemon
      end
    end
    disabled_vyatta_hosts = VyattaHost.where(:is_enabled => false)
    disabled_vyatta_hosts.each do |vyatta_host|
      if vyatta_host.vyatta_host_state.is_daemon_running
        vyatta_host.stop_daemon
      end
      if vyatta_host.daemon_running?
        vyatta_host.kill_all_daemons
      end
    end
    sleep(1)
  end
rescue => e
  if !rescue_chance_used
    rescue_chance_used = true
    Log.error("Error spotted(will retry): #{e.message}")
    sleep 5
    retry
  else
    Log.fatal("Error spotted(will exit): #{e.message}")
    exit(1)
  end
end