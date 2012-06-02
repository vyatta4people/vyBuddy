INSERT INTO `settings`(
	`name`,
	`value`,
	`validation_regex`,
	`validation_message`,
	`updated_at`
)
VALUES (
	'smtp_auth_type',
	'plain',
	'^(plain|login|cram_md5)$',
	'must be plain, login or cram_md5',
	NOW()
);

UPDATE `settings` SET `sort_order` = 1450 
	WHERE `name` = 'smtp_auth_type';

UPDATE `settings` SET `value_type` = 'p' 
	WHERE `name` = 'smtp_password';