CREATE TABLE `task_vyatta_host_groups` (
  `id` 						int(10) unsigned NOT NULL AUTO_INCREMENT,
  `task_id` 					int(10) unsigned NOT NULL,
  `vyatta_host_group_id` 		int(10) unsigned NOT NULL,
  `created_at` 				datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_task_vyatta_host_group_id` (`task_id`, `vyatta_host_group_id`),
  KEY `task_id` (`task_id`),
  KEY `vyatta_host_group_id` (`vyatta_host_group_id`),
  CONSTRAINT `task_vyatta_host_groups_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`),
  CONSTRAINT `task_vyatta_host_groups_ibfk_2` FOREIGN KEY (`vyatta_host_group_id`) REFERENCES `vyatta_host_groups` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Vyatta host groups scoped to certain task';