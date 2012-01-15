ALTER TABLE `task_groups` 			ADD COLUMN `sort_order` int(10) UNSIGNED NOT NULL DEFAULT 0 AFTER `name`;
ALTER TABLE `tasks` 				ADD COLUMN `sort_order` int(10) UNSIGNED NOT NULL DEFAULT 0 AFTER `name`;
ALTER TABLE `task_remote_commands` 	ADD COLUMN `sort_order` int(10) UNSIGNED NOT NULL DEFAULT 0 AFTER `filter_id`;