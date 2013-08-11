{
  initComponent: function(params) {
    this.superclass.initComponent.call(this);

    this.on('afterrender', function(self, eOpts) {
      // Define fellow components
      //this.tasksGrid = Netzke.page.manageTasksWindow.netzkeGetComponent('tasks_grid');
    }, this);

    //this.getStore().on('remove', function(self, eOpts) {
    //  this.tasksGrid.taskRemoteCommandsGrid.fireEvent('selecttask', this.tasksGrid.selectedTaskId, this.tasksGrid.selectedTaskName);
    //}, this);

    this.getView().on('itemdblclick', function(self, record, item, index, e, eOpts) {
      this.onEditInForm();
    }, this);
  }
}