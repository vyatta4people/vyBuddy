ALTER TABLE `logs` ADD COLUMN `event_source` VARCHAR(40) NOT NULL DEFAULT 'System' AFTER `application`;
CREATE INDEX `event_source` ON `logs`(`event_source`);

ALTER TABLE `logs` CHANGE COLUMN `application` `application` VARCHAR(20) NOT NULL DEFAULT 'system', CHANGE COLUMN `event_source` `event_source` VARCHAR(40) NOT NULL DEFAULT 'n/a';