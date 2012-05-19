ALTER TABLE 
	`vyatta_hosts` 
ADD COLUMN 
	`polling_interval` INT(10) UNSIGNED NOT NULL DEFAULT 60
AFTER `remote_port`;