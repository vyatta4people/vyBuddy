{
  onExecuteOnDemandTasks: function() {
    var mask = new Ext.LoadMask(Ext.getBody(), { msg: "Please wait for on-demand tasks execution..." });
    mask.show();
    this.executeTasks({ vyatta_host_id: this.selectedVyattaHostId, task_type: 'on_demand' }, function(result) {
      mask.hide();
      if (result.success) {
        Ext.Msg.show({ title: 'Execution successful', msg: result.message, buttons: Ext.Msg.OK, icon: Ext.Msg.INFO });
      } else {
        Ext.Msg.show({ title: 'Execution failed', msg: result.message, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR });
      }
    }, this);
  }
}