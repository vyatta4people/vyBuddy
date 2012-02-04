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

  onViewLogs: function() {
  	Netzke.page.logsWindow.show();
  },

  onShowHelp: function() {
		Ext.Msg.show({ title: 'Help', msg: 'vyBuddy by Ivan "Cartman" Ilves, 2012.<br/>It is early alpha! Be careful! :) :) :)', buttons: Ext.Msg.OK, icon: Ext.Msg.INFO });
  },

  onLogout: function() {
		window.location = '/auth/logout';
  }
}
