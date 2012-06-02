ALTER TABLE `settings` ADD COLUMN `sort_order` INT(10) UNSIGNED NOT NULL DEFAULT 0 AFTER `validation_message`;

INSERT INTO `settings`(`name`,`value`,`validation_regex`,`validation_message`)
VALUES (
	'smtp_use_auth',
	'0',
	'^[0-1]$',
	'must be 0 (off) or 1 (on)'
);

UPDATE `settings` SET `sort_order`=1000 WHERE `name` = 'smtp_host';
UPDATE `settings` SET `sort_order`=1100 WHERE `name` = 'smtp_port';
UPDATE `settings` SET `sort_order`=1200 WHERE `name` = 'smtp_use_auth';
UPDATE `settings` SET `sort_order`=1300 WHERE `name` = 'smtp_username';
UPDATE `settings` SET `sort_order`=1400 WHERE `name` = 'smtp_password';
UPDATE `settings` SET `sort_order`=1500 WHERE `name` = 'smtp_use_ssl';