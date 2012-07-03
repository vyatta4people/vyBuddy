{
  initComponent: function(params) {
    this.superclass.initComponent.call(this);

    this.selectedVyattaHostGroupId = 0;

    this.on('afterrender', function(self, eOpts) {
      // Define fellow components
      this.tasksGrid                = Netzke.page.manageTasksWindow.getChildNetzkeComponent('tasks_grid');
      this.taskDetailsTabPanel      = Netzke.page.manageTasksWindow.getChildNetzkeComponent('task_details_tab_panel');
      this.taskVyattaHostGroupsGrid = this.taskDetailsTabPanel.getChildNetzkeComponent('task_vyatta_host_groups_grid');
      // Load records
      this.getStore().load();
    }, this);

    this.getStore().on('load', function(self, records, successful, operation, eOpts) {
      if ((records) && (records.length > 0)) {
        var index = self.findExact('id', this.selectedVyattaHostGroupId);
        if (index == -1) { index = 0; }
        this.getSelectionModel().select(index);
        this.taskVyattaHostGroupsGrid.fireEvent('selecttask', this.tasksGrid.selectedTaskId, this.tasksGrid.selectedTaskName);
      }
    }, this);

    this.on('select', function(self, record, index, eOpts) {
      this.selectedVyattaHostGroupId = record.data.id;
    }, this);

    this.getView().on('beforedrop', function(node, data, dropRec, dropPosition) {
      if (data.view.ownerCt.id != 'manage_tasks_window__tasks_side_tab_panel__groups_tab_panel__vyatta_host_groups_grid') {
        this.getStore().load();
        return(false);
      }
    }, this);

    this.getView().on('drop', function(node, data, dropRec, dropPosition) {
      this.reorganizeWithPersistentOrder({ moved_record_id: data.records[0].data.id, replaced_record_id: dropRec.data.id, position: dropPosition }, function(result) {
        if (result.success) {
          this.getStore().load();
        } else {
          Ext.Msg.show({ title: 'Vyatta host group re-order failed', msg: result.message, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR });
        }
      });
    }, this);
    
    this.getView().on('itemdblclick', function(self, record, item, index, e, eOpts) {
      this.onEditInForm();
    }, this);
  }
}
