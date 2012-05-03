ALTER TABLE `tasks` ADD COLUMN `is_on_demand` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 AFTER `name`;
CREATE INDEX `is_on_demand` ON `tasks` (`is_on_demand`);