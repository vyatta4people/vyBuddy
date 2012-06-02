INSERT INTO `settings`(`name`,`value`,`validation_regex`,`validation_message`,`sort_order`)
VALUES (
	'smtp_from',
	'vybuddy@localhost',
	'^([a-z0-9_\-\.\+]+)\@((([a-z0-9\-]+\.)+)([a-z]{2,4})|[a-z0-9][a-z0-9\-]+)$',
	'must be in email format',
	1150
);