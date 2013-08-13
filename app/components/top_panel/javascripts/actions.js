{
  onManageTasks: function() {
    Netzke.page.manageTasksWindow.show();
  },

  onManageUsers: function() {
    Netzke.page.manageUsersWindow.show();
  },

  onManageSshKeyPairs: function() {
    Netzke.page.manageSshKeyPairsWindow.show();
  },

  onImportExport: function() {
    Netzke.page.importExportWindow.show();
  },

  onViewLogs: function() {
    Netzke.page.logsWindow.show();
  },

  onManageSettings: function() {
    Netzke.page.manageSettingsWindow.show();
  },

  onShowAbout: function() {
    Ext.Msg.show({
      title: 'About vyBuddy',
      msg: '<b style="font-size:medium;">vyBuddy 0.2.0 Beta (Grim Fandango)</b><br/><br/>' +
      'by Ivan "Cartman" Ilves, 2013<br/><br/>' +
      'Email us at <a href="mailto:vyatta4people@vyatta4people.org">vyatta4people@vyatta4people.org</a> or<br/>' +
      'visit <a href="http://www.vyatta4people.org/">www.vyatta4people.org</a> to leave a comment.<br/><br/>' +
      '<b>Thank you for using vyBuddy!</b>',
      buttons: Ext.Msg.OK, icon: Ext.Msg.INFO
    });
  },

  onLogout: function() {
    window.location = '/auth/logout';
  }
}
