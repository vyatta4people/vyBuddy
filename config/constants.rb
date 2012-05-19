#
# vyBuddy projects constants
#
DAEMONS_DIR                 = Rails.root.join('lib/daemons')
HOST_DAEMON_NAME            = :vyhostd
HOST_DAEMON_FILE            = HOST_DAEMON_NAME.to_s + '.rb'
HOST_DAEMON_PATH            = DAEMONS_DIR.join(HOST_DAEMON_FILE)
GRACE_PERIOD                = 1
RETRY_PERIOD                = 5

EMAIL_REGEX                 = /^([a-z0-9_\-\.\+]+)\@((([a-z0-9\-]+\.)+)([a-z]{2,4})|[a-z0-9][a-z0-9\-]+)$/
EMAIL_REASON                = 'must be in email format'
USERNAME_REGEX              = /^[a-z][a-z0-9\-]+$/
USERNAME_REASON             = 'must start from lowercase letter and contain only lowercase letters, numbers and hyphens'

SSH_KEY_TYPES               = ['ssh-rsa', 'ssh-dss']
SSH_TIMEOUT                 = 30
REMOTE_COMMAND_MODES        = [:system, :operational, :configuration]
DEFAULT_REMOTE_COMMAND_MODE = :operational
INTERPRETERS                = ['/bin/bash', '/usr/bin/perl', '/usr/bin/ruby']
EXECUTORS_LOCAL_DIR         = 'vendor/vybuddy/executors'
EXECUTORS_REMOTE_DIR        = '/var/tmp'

DEFAULT_USER_ID             = 1
DEFAULT_FILTER_NAME         = 'AS-IS'

DUMMY_DISPLAY_INFORMATION   = '<i>Not applicable to this host...</i>'

LOG_SEVERITIES              = [:DEBUG, :ERROR, :FATAL, :INFO, :WARN, :CUSTOM]
KEEP_LOG_RECORDS            = 10000

CSS_BORDER_STYLE            = '1px #99bce8 solid'
