{
  initComponent: function(params) {
    this.superclass.initComponent.call(this);

    this.selectedTaskId       = 0;
    this.selectedTaskGroupId  = 0;
    this.selectedTaskName     = '';

    this.on('afterrender', function(self, eOpts) {
      // Define fellow components
      this.taskRemoteCommandsGrid = Netzke.page.manageTasksWindow.getChildNetzkeComponent('task_remote_commands_grid');
      // Load records
      this.getStore().load();
    }, this);

    this.getStore().on('load', function(self, records, successful, operation, eOpts) {
      if ((records) && (records.length > 0)) {
        if (this.taskRemoteCommandsGrid.isDisabled()) { this.taskRemoteCommandsGrid.setDisabled(false); }
        if (this.selectedTaskId == 0) { 
          this.getSelectionModel().select(0);
        } else {
          var index = self.findExact('id', this.selectedTaskId);
          if (index == -1) { index = 0; }
          this.getSelectionModel().select(index);
        }
      } else {
        this.taskRemoteCommandsGrid.getStore().load();
        if (!this.taskRemoteCommandsGrid.isDisabled()) { this.taskRemoteCommandsGrid.setDisabled(true); }
      }
    }, this);

    this.on('select', function(self, record, index, eOpts) {
      this.selectedTaskId       = record.data.id;
      this.selectedTaskGroupId  = record.data.task_group__name;
      this.selectedTaskName     = record.data.name;
      this.taskRemoteCommandsGrid.fireEvent('selecttask', this.selectedTaskId, this.selectedTaskName);
    }, this);

    this.getView().on('drop', function(node, data, dropRec, dropPosition) {
      this.reorganizeWithPersistentOrder({ moved_record_id: data.records[0].data.id, replaced_record_id: dropRec.data.id, position: dropPosition }, function(result) {
        if (result.success) {
          this.getStore().load();
        } else {
          Ext.Msg.show({ title: 'Task re-order failed', msg: result.message, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR });
        }
      });
    }, this);
    
    this.getView().on('itemdblclick', function(self, record, item, index, e, eOpts) {
      this.onEditInForm();
    }, this);
  }
}
