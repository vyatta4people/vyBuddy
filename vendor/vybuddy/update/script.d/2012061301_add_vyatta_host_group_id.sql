-- Connect Vyatta hosts to Vyatta host groups and generate defaults

INSERT INTO 
	`vyatta_host_groups` (`id`, `name`) 
VALUES 
	(1, 'Default');

UPDATE `vyatta_host_groups` SET `created_at` = NOW(), `updated_at` = NOW() WHERE `id` = 1;

ALTER TABLE 
	`vyatta_hosts` 
ADD COLUMN 
	`vyatta_host_group_id` int(10) unsigned NOT NULL DEFAULT 1 AFTER `id`;

CREATE INDEX 
	`vyatta_host_group_id` 
ON 
	`vyatta_hosts` (`vyatta_host_group_id`);

ALTER TABLE
	`vyatta_hosts`
ADD FOREIGN KEY (`vyatta_host_group_id`) REFERENCES `vyatta_host_groups` (`id`);
