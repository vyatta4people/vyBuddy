CREATE TABLE `settings` (
  `id`					int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` 				varchar(255) NOT NULL,
  `value` 				varchar(255) NOT NULL,
  `validation_regex` 		varchar(255) NOT NULL DEFAULT ".*",
  `validation_message` 	varchar(255) NOT NULL DEFAULT "",
  `updated_at` 			datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`), UNIQUE KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='vyBuddy settings'
