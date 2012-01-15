{
  initComponent: function(params) {
  	this.superclass.initComponent.call(this);

  	this.on('afterrender', function(self, eOpts) {
  		this.getSelectionModel().select(0);
  	}, this);

 		this.on('select', function(self, record, index, eOpts) {
  		Netzke.page.manageTasksWindow.getChildNetzkeComponent('task_remote_commands_grid').fireEvent('selecttask', record.data.id, record.data.name);
  	}, this);
  }
}
