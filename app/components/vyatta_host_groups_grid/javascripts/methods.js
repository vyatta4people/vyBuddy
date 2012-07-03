{
  afterDelete: function(data) {
    this.reorderRecords({ }, function (result) {
      if (!result.success) { Ext.Msg.show({ title: 'Re-Order failed', msg: result.message, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR }); }
    });
    this.getStore().load();
    this.taskVyattaHostGroupsGrid.fireEvent('selecttask', this.tasksGrid.selectedTaskId, this.tasksGrid.selectedTaskName);
  }
}
