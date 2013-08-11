{
  initComponent: function(params) {
    this.superclass.initComponent.call(this);

    this.selectedTaskGroupId = 0;

    this.on('afterrender', function(self, eOpts) {
      // Define fellow components
      this.tasksGrid = Netzke.page.manageTasksWindow.netzkeGetComponent('tasks_grid');
      // Load records
      this.getStore().load();
    }, this);

    this.getStore().on('load', function(self, records, successful, operation, eOpts) {
      if ((records) && (records.length > 0)) {
        if (this.tasksGrid.isDisabled()) { this.tasksGrid.setDisabled(false); }
          var index = self.findExact('id', this.selectedTaskGroupId);
          if (index == -1) { index = 0; }
          this.getSelectionModel().select(index);
        } else {
        if (!this.tasksGrid.isDisabled()) { this.tasksGrid.setDisabled(true); }
      }
    }, this);

    this.on('select', function(self, record, index, eOpts) {
      this.selectedTaskGroupId = record.data.id;
    }, this);

    this.getStore().on('datachanged', function(self, eOpts) {
      this.tasksGrid.getStore().load();
    }, this);

    this.getView().on('drop', function(node, data, dropRec, dropPosition) {
      this.reorganizeWithPersistentOrder({ moved_record_id: data.records[0].data.id, replaced_record_id: dropRec.data.id, position: dropPosition }, function(result) {
        if (result.success) {
          this.getStore().load();
          this.tasksGrid.fireEvent('droptaskgroup', data.records[0].data.id);
        } else {
          Ext.Msg.show({ title: 'Task group re-order failed', msg: result.message, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR });
        }
      });
    }, this);
    
    this.getView().on('itemdblclick', function(self, record, item, index, e, eOpts) {
      this.onEditInForm();
    }, this);
  }
}
