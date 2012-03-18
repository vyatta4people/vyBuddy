ALTER TABLE `logs` ADD COLUMN `is_verbose` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 AFTER `severity`;
CREATE INDEX `is_verbose` ON `logs` (`is_verbose`);