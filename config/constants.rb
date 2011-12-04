#
# vyBuddy projects constants
#
DAEMONS_DIR           = Rails.root.join('lib/daemons')
HOST_DAEMON_NAME      = 'vyhostd'
HOST_DAEMON_FILE      = HOST_DAEMON_NAME + '.rb'
HOST_DAEMON_PATH      = DAEMONS_DIR.join(HOST_DAEMON_FILE)

SSH_TIMEOUT           = 30
REMOTE_COMMAND_MODES  = ["operational", "configuration", "system"]
