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

  onShowAbout: function() {
    Ext.Msg.show({ title: 'About', msg: 'vyBuddy by Ivan "Cartman" Ilves, 2012.<br/><br/>It is early alpha, so there are still many troubles... ;)<br/><br/><b>Thank you for using vyBuddy!</b>', buttons: Ext.Msg.OK, icon: Ext.Msg.INFO });
  },

  onLogout: function() {
    window.location = '/auth/logout';
  }
}
