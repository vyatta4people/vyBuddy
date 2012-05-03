#!/usr/bin/ruby
#
# vyBuddy master daemon - starts and stops vyhostd processes
#

require File.expand_path('../../../config/environment', __FILE__)

Log.application         = :vymasterd
Log.event_source        = 'localhost'
Log.duplicate_to_stderr = true

def graceful_shutdown
  vyatta_hosts = VyattaHost.all
  vyatta_hosts.each do |vyatta_host|
    if vyatta_host.vyatta_host_state.is_daemon_running
      vyatta_host.stop_daemon
    end
    sleep(GRACE_PERIOD)
    if vyatta_host.daemon_running?
      vyatta_host.kill_all_daemons
    end
  end
  Log.info("Daemon stopped")
  exit(0)
end
Signal.trap("TERM") { graceful_shutdown }
Signal.trap("INT")  { graceful_shutdown }

Log.info("Daemon started")

rescue_chance_used = false
begin
  while true do
    enabled_vyatta_hosts = VyattaHost.enabled
    enabled_vyatta_hosts.each do |vyatta_host|
      if !vyatta_host.vyatta_host_state.is_daemon_running or !vyatta_host.daemon_running?
        if !vyatta_host.start_daemon
          Log.fatal("Unable to start vyHostD for #{vyatta_host.hostname}(#{vyatta_host.id.to_s}): #{vyatta_host.start_daemon_error}")
        end
      end
    end
    disabled_vyatta_hosts = VyattaHost.disabled
    disabled_vyatta_hosts.each do |vyatta_host|
      if vyatta_host.vyatta_host_state.is_daemon_running
        if !vyatta_host.stop_daemon
          Log.fatal("Unable to stop vyHostD for #{vyatta_host.hostname}(#{vyatta_host.id.to_s}): #{vyatta_host.stop_daemon_error}")
        end
      end
      sleep(GRACE_PERIOD)
      if vyatta_host.daemon_running?
        Log.warn("Need to use silver bullets to stop vyHostD for #{vyatta_host.hostname}(#{vyatta_host.id.to_s})")
        vyatta_host.kill_all_daemons
      end
    end
    sleep(GRACE_PERIOD)
  end
rescue => e
  if !rescue_chance_used
    rescue_chance_used = true
    Log.error("Error spotted(will retry): #{e.message}")
    sleep(RETRY_PERIOD)
    retry
  else
    Log.fatal("Error spotted(will exit): #{e.message}")
    exit(1)
  end
end
