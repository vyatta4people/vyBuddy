ALTER TABLE `settings`
	ADD COLUMN `value_type` VARCHAR(1) NOT NULL DEFAULT 's' AFTER `value`;

CREATE INDEX `value_type` 
	ON `settings` (`value_type`);

UPDATE `settings` SET `value_type` = 'i' WHERE `name` = 'smtp_port';
UPDATE `settings` SET `value_type` = 'b' WHERE `name` = 'smtp_use_ssl';