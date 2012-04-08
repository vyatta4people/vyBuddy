ALTER TABLE 
	`vyatta_hosts` 
ADD COLUMN 
	`remote_port` INT(10) UNSIGNED NOT NULL DEFAULT 22 
AFTER `remote_address`;