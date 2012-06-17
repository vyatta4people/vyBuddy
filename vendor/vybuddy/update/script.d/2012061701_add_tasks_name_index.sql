DROP INDEX `name` ON `tasks`;
CREATE UNIQUE INDEX `task_group_id_name` ON `tasks` (`task_group_id`,`name`);