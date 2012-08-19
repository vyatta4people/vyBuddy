ALTER TABLE `task_remote_commands`
ADD COLUMN
	`command_extension` VARCHAR(255) NOT NULL DEFAULT ""
AFTER `remote_command_id`;