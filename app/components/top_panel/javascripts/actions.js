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
		Ext.Msg.show({ title: 'Help', msg: 'vyBuddy pre-alpha! Be careful! :)', buttons: Ext.Msg.OK, icon: Ext.Msg.INFO });
  },

  onLogout: function() {
		window.location = '/auth/login';
  }
}
