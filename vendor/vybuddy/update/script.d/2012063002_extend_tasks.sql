ALTER TABLE `tasks`
	ADD COLUMN `is_singleton` tinyint(1) unsigned NOT NULL DEFAULT 0 AFTER `is_on_demand`;

ALTER TABLE `tasks` 
	ADD COLUMN `group_applicability` varchar(20) NOT NULL DEFAULT 'global' AFTER `is_singleton`;

CREATE INDEX `is_singleton` ON `tasks` (`is_singleton`);
CREATE INDEX `group_applicability` ON `tasks` (`group_applicability`);

