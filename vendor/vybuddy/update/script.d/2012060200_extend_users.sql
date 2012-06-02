ALTER TABLE `users`
	ADD COLUMN `receives_notifications` TINYINT(1) NOT NULL DEFAULT 0 AFTER `password`;

CREATE INDEX `receives_notifications` ON `users` (`receives_notifications`);