{
  initComponent: function(params) {
  	this.superclass.initComponent.call(this);

  	this.on('afterrender', function(self, eOpts) {
      this.getStore().load();
  	}, this);

 	 	this.getStore().on('load', function(self, records, successful, operation, eOpts) {
	 	  if ((records) && (records.length > 0)) { 
	  		this.getSelectionModel().select(0);
	    }
  	}, this);

 		this.getView().on('drop', function(node, data, dropRec, dropPosition) {
			this.reorganizeWithPersistentOrder({ moved_record_id: data.records[0].data.id, replaced_record_id: dropRec.data.id }, function(result) {
				if (result.success) {
			    this.getStore().load();
			    Netzke.page.manageTasksWindow.getChildNetzkeComponent('tasks_grid').fireEvent('droptaskgroup', data.records[0].data.id);
				} else {
				  Ext.Msg.show({ title: 'Task group re-order failed', msg: result.message, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR });
				}
			});
  	}, this);
  }
}
