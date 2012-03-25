--
-- Get rid of useless displays, task_remote_commands and finally remote_commands!
--
DELETE FROM `displays` WHERE `task_remote_command_id` IN (
	SELECT `id` FROM `task_remote_commands` WHERE `remote_command_id` IN (
		SELECT `id` FROM `remote_commands` WHERE `command`="show version | grep 'Version' | sed 's/.*: *//'" OR `command`="uptime | sed 's/.*, //'"
));

DELETE FROM `task_remote_commands` WHERE `remote_command_id` IN (
	SELECT `id` FROM `remote_commands` WHERE `command`="show version | grep 'Version' | sed 's/.*: *//'" OR `command`="uptime | sed 's/.*, //'"
);

DELETE FROM `remote_commands` WHERE `command`="show version | grep 'Version' | sed 's/.*: *//'" OR `command`="uptime | sed 's/.*, //'";
