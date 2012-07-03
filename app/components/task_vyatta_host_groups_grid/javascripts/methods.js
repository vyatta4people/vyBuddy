{
  afterDelete: function(data) {
    this.fireEvent('selecttask', this.tasksGrid.selectedTaskId, this.tasksGrid.selectedTaskName);
  }
}