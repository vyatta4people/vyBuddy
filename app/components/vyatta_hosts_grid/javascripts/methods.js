{
  onExecuteTasks: function(taskType) {
    var mask = new Ext.LoadMask(Ext.getBody(), { msg: "Please wait for tasks execution..." });
    mask.show();
    this.executeTasks({ vyatta_host_id: this.selectedVyattaHostId, task_type: taskType }, function(result) {
      this.displayTasksTabPanel.fireEvent('selectvyattahost', this.selectedVyattaHostId);
      mask.hide();
      netzkeEndpointHandler(result);
    }, this);
  }
}
