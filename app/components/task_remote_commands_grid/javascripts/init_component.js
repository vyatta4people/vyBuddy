{
  initComponent: function(params) {
  	this.superclass.initComponent.call(this);

  	this.on('afterrender', function(self, eOpts) {
      if (this.getStore().getCount() > 0) {
      	this.getSelectionModel().select(0);
      }
  	}, this);

  	this.on('selecttask', function(taskId, taskName) {
  		var store = this.getStore();
  		var proxy = store.getProxy();
  		proxy.extraParams.query = Ext.encode([ [ { attr: "task_id", value: taskId, operator: "eq" } ] ]);
  	  store.load();
			this.setTitle('Remote commands for \"' + taskName + '\"');
  	}, this);
  }
}
