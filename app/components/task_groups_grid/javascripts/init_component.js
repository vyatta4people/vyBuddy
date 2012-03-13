{
  initComponent: function(params) {
  	this.superclass.initComponent.call(this);

		this.selectedTaskGroupId  = 0;

  	this.on('afterrender', function(self, eOpts) {
      this.getStore().load();
  	}, this);

 	 	this.getStore().on('load', function(self, records, successful, operation, eOpts) {
	 	  var tasksGrid = Netzke.page.manageTasksWindow.getChildNetzkeComponent('tasks_grid');
	 	  if ((records) && (records.length > 0)) {
	 	  	if (tasksGrid.isDisabled()) { tasksGrid.setDisabled(false); }
	  		this.getSelectionModel().select(0);
	    } else {
	    	if (!tasksGrid.isDisabled()) { tasksGrid.setDisabled(true); }
	   	}
  	}, this);

 		this.on('select', function(self, record, index, eOpts) {
 			this.selectedTaskGroupId = record.data.id;
  	}, this);

 	 	this.getStore().on('datachanged', function(self, eOpts) {
	  	Netzke.page.manageTasksWindow.getChildNetzkeComponent('tasks_grid').getStore().load();
  	}, this);

 		this.getView().on('drop', function(node, data, dropRec, dropPosition) {
			this.reorganizeWithPersistentOrder({ moved_record_id: data.records[0].data.id, replaced_record_id: dropRec.data.id, position: dropPosition }, function(result) {
				if (result.success) {
			    this.getStore().load();
			    Netzke.page.manageTasksWindow.getChildNetzkeComponent('tasks_grid').fireEvent('droptaskgroup', data.records[0].data.id);
				} else {
				  Ext.Msg.show({ title: 'Task group re-order failed', msg: result.message, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR });
				}
			});
  	}, this);
  },

  afterDelete: function(data) {
    this.reorderRecords({ selected_task_group_id: this.selectedTaskGroupId }, function (result) { if (!result.success) { Ext.Msg.show({ title: 'Re-Order failed', msg: result.message, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR }); } });
  	this.getStore().load();
  }
}
