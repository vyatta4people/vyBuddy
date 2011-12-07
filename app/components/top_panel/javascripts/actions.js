{
  onManageUsers: function() {
		Netzke.page.manageUsersWindow.show();
  },

  onManageSshKeyPairs: function() {
		Netzke.page.manageSshKeyPairsWindow.show();
  },

  onManageTasks: function() {
		Netzke.page.manageTasksWindow.show();
  },

  onShowHelp: function() {
		Ext.MessageBox.show({
			title: 'Help',
			msg: 'vyBuddy pre-alpha! Be careful! :)',
			modal: true,
			icon: Ext.Msg.INFO,
			buttons: Ext.Msg.OK
		});
  }
}
