{
  initComponent: function(params) {
  	this.superclass.initComponent.call(this);

  	this.on('afterrender', function(self, eOpts) {
      if (this.getStore().getCount() > 0) {
      	this.getSelectionModel().select(0);
      }
  	}, this);

  	this.on('selecttask', function(taskName) {
			this.setTitle('Remote commands for \"' + taskName + '\"');
  	}, this);
  }
}
