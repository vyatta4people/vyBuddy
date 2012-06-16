-- Disconnect Vyatta hosts from users

ALTER TABLE 
	`vyatta_hosts`
DROP FOREIGN KEY 
	`vyatta_hosts_ibfk_1`;

ALTER TABLE
	`vyatta_hosts`
DROP COLUMN 
	`user_id`;
