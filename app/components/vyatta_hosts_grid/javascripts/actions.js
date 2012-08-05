{
  onBulkAdd: function() {
    Netzke.page.vyattaHostsBulkAddWindow.show();
  },

  onExecuteAllTasks: function() {
    this.onExecuteTasks('all');
  },

  onExecuteOnDemandTasks: function() {
    this.onExecuteTasks('on_demand');
  },

  onExecuteBackgroundTasks: function() {
    this.onExecuteTasks('background');
  }
}