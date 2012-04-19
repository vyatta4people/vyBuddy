#!/usr/bin/ruby
#
# Check vyMaster daemon status and restart if needed
#

status = `vybuddyctl status`.sub(/^.* status: */, '').strip

if status == 'Failed!'
  require File.expand_path('../../../config/environment', __FILE__)
  Log.application   = :watchdog
  Log.event_source  = 'localhost'
  if system('vybuddyctl restart >/dev/null 2>&1')
    Log.warn('vyMasterD was successfully restarted by watchdog')
  else
    Log.fatal('Watchdog was unable to restart vyMasterD')
  end
end
