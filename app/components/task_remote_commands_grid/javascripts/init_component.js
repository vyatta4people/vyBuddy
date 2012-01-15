{
  initComponent: function(params) {
  	this.superclass.initComponent.call(this);

 	  this.store.on('load', function(self, records, successful, operation, eOpts) {
  		this.getSelectionModel().select(0);
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
