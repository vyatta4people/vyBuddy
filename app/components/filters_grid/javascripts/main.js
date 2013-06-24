{
  initComponent: function(params) {
    this.superclass.initComponent.call(this);

    this.on('afterrender', function(self, eOpts) {
      // Define fellow components
      this.tasksGrid = Netzke.page.manageTasksWindow.getChildNetzkeComponent('tasks_grid');
    }, this);

    this.getStore().on('datachanged', function(self, eOpts) {
      this.tasksGrid.getStore().load();
    }, this);

    this.getView().on('itemdblclick', function(self, record, item, index, e, eOpts) {
      this.onEditInForm();
    }, this);
  }
}