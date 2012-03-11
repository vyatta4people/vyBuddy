{
  initComponent: function(params) {
  	this.superclass.initComponent.call(this);

  	this.on('afterrender', function(self, eOpts) {
      var dropTargetEl 	= this.body.dom;
      var dropTarget 		= Ext.create('Ext.dd.DropTarget', dropTargetEl, {
        ddGroup: 'remote_commands_dd_group',
        notifyEnter: function(ddSource, e, data) {
        	var targetGrid = Netzke.page.manageTasksWindow.getChildNetzkeComponent('task_remote_commands_grid');
        	if (ddSource.id == 'manage_tasks_window__tasks_side_tab_panel__remote_commands_grid-body') {
	        	targetGrid.body.stopAnimation();
	        	targetGrid.body.highlight();
        	}
      	}
      });
  	}, this);

 	  this.getStore().on('load', function(self, records, successful, operation, eOpts) {
	 	  if ((records) && (records.length > 0)) {
	  		this.getSelectionModel().select(0);
	    }
  	}, this);

  	this.on('selecttask', function(taskId, taskName) {
  		var store = this.getStore();
  		var proxy = store.getProxy();
  		proxy.extraParams.query = Ext.encode([ [ { attr: "task_id", value: taskId, operator: "eq" } ] ]);
  	  store.load();
  	}, this);

  	this.getView().on('drop', function(node, data, dropRec, dropPosition) {
			var movedRecordId = data.records[0].data.id;
			if (dropRec) { var replacedRecordId 	= dropRec.data.id; } else { var replacedRecordId 	= 0; }
  		if (data.view.ownerCt.id == 'manage_tasks_window__tasks_side_tab_panel__remote_commands_grid') { var local = false; } else { var local = true; }
			var tasksGrid 					= Netzke.page.manageTasksWindow.getChildNetzkeComponent('tasks_grid');
			var remoteCommandsGrid 	= Netzke.page.manageTasksWindow.getChildNetzkeComponent('tasks_side_tab_panel').getChildNetzkeComponent('remote_commands_grid');
			this.reorganizeWithPersistentOrder({ moved_record_id: movedRecordId, replaced_record_id: replacedRecordId, local: local, selected_task_id: tasksGrid.selectedTaskId, position: dropPosition }, function(result) {
			  this.getStore().load();
			  if (!result.local) { remoteCommandsGrid.getStore().load(); }
				if (!result.success) {
			    if (result.local) { var title = 'Remote command re-order failed'; } else { var title = 'Failed to add remote command'; }
				  Ext.Msg.show({ title: title, msg: result.message, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR });
				}
			});
  	}, this);
  },

  reloadRemoteCommands: function(data) {
    var tasksGrid = Netzke.page.manageTasksWindow.getChildNetzkeComponent('tasks_grid');
    this.reorderRecords({ selected_task_id: tasksGrid.selectedTaskId }, function (result) { if (!result.success) { Ext.Msg.show({ title: 'Re-Order failed', msg: result.message, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR }); } });
    this.fireEvent('selecttask', tasksGrid.selectedTaskId, tasksGrid.selectedTaskName);
  }
}