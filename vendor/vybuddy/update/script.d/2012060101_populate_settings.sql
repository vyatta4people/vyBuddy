INSERT INTO `settings`(`name`,`value`,`validation_regex`,`validation_message`)
VALUES (
	'smtp_host',
	'127.0.0.1',
	'^(([1-2]?[0-9]{1,2}\.){3}[1-2]?[0-9]{1,2}|[a-z0-9][a-z0-9\.\-]+[a-z])$',
	'must be valid DNS name or IPv4 address'
);

INSERT INTO `settings`(`name`,`value`,`validation_regex`,`validation_message`)
VALUES (
	'smtp_port',
	'25',
	'^([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$',
	'must be valid TCP port number'
);

INSERT INTO `settings`(`name`,`value`)
VALUES (
	'smtp_username',
	''
);

INSERT INTO `settings`(`name`,`value`)
VALUES (
	'smtp_password',
	''
);

INSERT INTO `settings`(`name`,`value`,`validation_regex`,`validation_message`)
VALUES (
	'smtp_use_ssl',
	'0',
	'^[0-1]$',
	'must be 0 (off) or 1 (on)'
);

UPDATE `settings` SET `updated_at`='2012-06-01 22:44:00';