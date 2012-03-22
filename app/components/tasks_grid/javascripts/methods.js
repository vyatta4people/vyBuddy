{
  afterDelete: function(data) {
    this.reorderRecords({ selected_task_group_id: this.selectedTaskGroupId }, function (result) { 
      if (!result.success) { Ext.Msg.show({ title: 'Re-Order failed', msg: result.message, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR }); } 
    });
    this.getStore().load();
  }
}
