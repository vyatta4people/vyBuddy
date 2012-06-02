ALTER TABLE `vyatta_hosts` 
	ADD COLUMN `is_monitored` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0
	AFTER `is_passive`;

CREATE INDEX `is_monitored` ON `vyatta_hosts` (`is_monitored`);