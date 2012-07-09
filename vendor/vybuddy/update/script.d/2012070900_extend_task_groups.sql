ALTER TABLE `task_groups` 
	ADD COLUMN 
		`fill_tab_with_color` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 AFTER `color`;
CREATE INDEX `fill_tab_with_color` ON `task_groups`(`fill_tab_with_color`);