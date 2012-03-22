{
  afterDelete: function(data) {
    this.reorderRecords({ selected_task_id: this.tasksGrid.selectedTaskId }, function (result) { 
      if (!result.success) { Ext.Msg.show({ title: 'Re-Order failed', msg: result.message, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR }); }
    });
    this.fireEvent('selecttask', this.tasksGrid.selectedTaskId, this.tasksGrid.selectedTaskName);
  }
}