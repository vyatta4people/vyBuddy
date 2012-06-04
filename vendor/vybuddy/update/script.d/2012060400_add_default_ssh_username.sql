-- Default SSH username
INSERT INTO `settings`(
	`name`,
	`value`,
	`validation_regex`,
	`validation_message`,
	`updated_at`,
	`sort_order`
)
VALUES (
	'default_ssh_username',
	'vybuddy',
	'^[a-z][a-z0-9\\- ]{1,39}$',
	'must be 2 to 40 character string starting from lowercase letter and containing only lowercase letters, numbers and hyphens',
	NOW(), 
	500
);
