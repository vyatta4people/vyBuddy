{
  initComponent: function(params) {
  	this.superclass.initComponent.call(this);

  	this.on('afterrender', function(self, eOpts) {
      this.getSelectionModel().select(0);
  	}, this);

  	this.store.on('load', function(self, records, successful, operation, eOpts) {
  		if (selectedFirstTime) {
  			this.selectedFirstTime = false;
  			this.getSelectionModel().select(this.selectedTasksGridRow);
  		}
  	}, this);

 		this.on('select', function(self, record, index, eOpts) {
  		this.selectedTaskId 				= record.data.id;
  		this.selectedTaskName 			= record.data.name;
  		this.selectedTasksGridRow 	= index;
  		Netzke.page.manageTasksWindow.getChildNetzkeComponent('task_remote_commands_grid').fireEvent('selecttask', this.selectedTaskId, this.selectedTaskName);
  	}, this);
  }
}
