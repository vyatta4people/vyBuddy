ALTER TABLE `tasks`
	ADD COLUMN `is_writer` tinyint(1) unsigned NOT NULL DEFAULT 0 AFTER `is_singleton`;

CREATE INDEX `is_writer` ON `tasks` (`is_writer`);