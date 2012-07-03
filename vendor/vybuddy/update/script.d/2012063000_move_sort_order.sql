ALTER TABLE `settings` 
	MODIFY COLUMN `sort_order` int(10) unsigned NOT NULL DEFAULT 0 AFTER `updated_at`;

ALTER TABLE `task_groups` 
	MODIFY COLUMN `sort_order` int(10) unsigned NOT NULL DEFAULT 0 AFTER `updated_at`;

ALTER TABLE `task_remote_commands` 
	MODIFY COLUMN `sort_order` int(10) unsigned NOT NULL DEFAULT 0 AFTER `updated_at`;

ALTER TABLE `tasks` 
	MODIFY COLUMN `sort_order` int(10) unsigned NOT NULL DEFAULT 0 AFTER `updated_at`;

ALTER TABLE `vyatta_host_groups` 
	MODIFY COLUMN `sort_order` int(10) unsigned NOT NULL DEFAULT 0 AFTER `updated_at`;

ALTER TABLE `vyatta_hosts` 
	MODIFY COLUMN `sort_order` int(10) unsigned NOT NULL DEFAULT 0 AFTER `updated_at`;