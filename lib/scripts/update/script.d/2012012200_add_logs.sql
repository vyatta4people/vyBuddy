CREATE TABLE `logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_date` date NOT NULL DEFAULT '0000-00-00',
  `application` varchar(20) NOT NULL DEFAULT 'default',
  `severity` varchar(10) NOT NULL DEFAULT 'UNKNOWN',
  `message` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `created_date` (`created_date`),
  KEY `application` (`application`),
  KEY `severity` (`severity`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='vyBuddy logs';