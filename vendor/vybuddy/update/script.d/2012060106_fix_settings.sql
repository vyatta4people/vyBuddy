UPDATE `settings` SET `value_type` = 'b' WHERE `name` = 'smtp_use_auth';

UPDATE `settings`
	SET `validation_regex` = '^(([1-2]?[0-9]{1,2}\\.){3}[1-2]?[0-9]{1,2}|[a-z0-9][a-z0-9\\.\\-]+[a-z])$' 
	WHERE `name` = 'smtp_host';

UPDATE `settings`
	SET 
		`validation_regex` = '^([a-z0-9_\\-\\.\\+]+)\\@((([a-z0-9\\-]+\\.)+)([a-z]{2,4})|[a-z0-9][a-z0-9\\-]+)$',
		`updated_at` = NOW()
	WHERE `name` = 'smtp_from';


