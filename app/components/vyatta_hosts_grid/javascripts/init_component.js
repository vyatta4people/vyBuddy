{
  initComponent: function(params) {
    this.superclass.initComponent.call(this);

    this.selectedVyattaHostId = 0;
    this.selectedRow          = 0;

    this.on('afterrender', function(self, eOpts) {
      var updateVyattaHostsGrid = function() { self.store.load(); }
      Ext.TaskManager.start({ run: updateVyattaHostsGrid, interval: 5000 });
      // Declare shorthand to fellow component
      this.displayTasksTabPanel = Netzke.page.vybuddyApp.getChildNetzkeComponent('display_tasks_tab_panel');
    }, this);

    this.getStore().on('load', function(self, records, successful, operation, eOpts) {
      if ((records) && (records.length > 0)) { 
        this.getSelectionModel().select(this.selectedRow);
      }
    }, this);

    this.on('select', function(self, record, index, eOpts) {
      this.selectedVyattaHostId   = record.data.id;
      this.selectedRow            = index;
      this.actions.executeOnDemandTasks.setDisabled(!record.data.is_enabled || !record.data.is_daemon_running || !record.data.is_reachable);
      this.displayTasksTabPanel.fireEvent('selectvyattahost', this.selectedVyattaHostId);
    }, this);

    this.getView().on('itemdblclick', function(self, record, item, index, e, eOpts) {
      this.getUserRights({ action: 'edit_in_form' }, function(userIsAdmin) {
        if (userIsAdmin) {
          this.onEditInForm();
        } else {
          Ext.Msg.show({ title: 'Access denied', msg: 'You have no rights to perform edit action!', buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR });
        }
      });
    }, this);
  }
}
