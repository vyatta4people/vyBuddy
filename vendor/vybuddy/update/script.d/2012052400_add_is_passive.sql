ALTER TABLE `vyatta_hosts` ADD COLUMN `is_passive` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 AFTER `polling_interval`;
CREATE INDEX `is_passive` ON `vyatta_hosts` (`is_passive`);