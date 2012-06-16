{
  onExecuteTasks: function(taskType) {
    var mask = new Ext.LoadMask(Ext.getBody(), { msg: "Please wait for tasks execution..." });
    mask.show();
    this.executeTasks({ vyatta_host_id: this.selectedVyattaHostId, task_type: taskType }, function(result) {
      this.displayTasksTabPanel.fireEvent('selectvyattahost', this.selectedVyattaHostId);
      mask.hide();
      netzkeEndpointHandler(result);
    }, this);
  },
  
  afterDelete: function(data) {
    this.reorderRecords({ selected_vyatta_host_group_id: this.selectedVyattaHostGroupId }, function (result) { 
      if (!result.success) { Ext.Msg.show({ title: 'Re-Order failed', msg: result.message, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR }); } 
    });
    this.getStore().load();
  }
}
