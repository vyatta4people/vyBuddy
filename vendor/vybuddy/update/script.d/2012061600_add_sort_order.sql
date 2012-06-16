ALTER TABLE `vyatta_hosts` ADD COLUMN `sort_order` int(10) UNSIGNED NOT NULL DEFAULT 0 AFTER `polling_interval`;
