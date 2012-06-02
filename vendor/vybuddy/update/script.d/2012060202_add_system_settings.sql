-- System name
INSERT INTO `settings`(
	`name`,
	`value`,
	`validation_regex`,
	`validation_message`,
	`updated_at`,
	`sort_order`
)
VALUES (
	'system_name',
	'vyBuddy',
	'^[a-zA-Z][a-zA-Z0-9_\\- ]{1,19}$',
	'must be 2 to 20 character string starting from a letter',
	NOW(), 
	100
);

-- System URL
INSERT INTO `settings`(
	`name`,
	`value`,
	`validation_regex`,
	`validation_message`,
	`updated_at`,
	`sort_order`
)
VALUES (
	'system_url',
	'https://vybuddy/',
	'^https?:\\/\\/(([1-2]?[0-9]{1,2}\\.){3}[1-2]?[0-9]{1,2}|[a-z0-9][a-z0-9\\.\\-]+[a-z])\\/?$',
	'must be valid HTTPS/HTTP URL',
	NOW(), 
	100
);