{
  initComponent: function(params) {
  	this.superclass.initComponent.call(this);

		this.selectedRow = 0;

  	this.on('afterrender', function(self, eOpts) {
  		var updateVyattaHostsGrid = function() { self.store.load(); }
			Ext.TaskManager.start({ run: updateVyattaHostsGrid, interval: 5000 });
  	}, this);

  	this.store.on('load', function(self, records, successful, operation, eOpts) {
  		this.getSelectionModel().select(this.selectedRow);
  	}, this);

  	this.on('select', function(self, record, index, eOpts) {
  		this.selectedRow = index;
  		Netzke.page.vybuddyApp.getChildNetzkeComponent('display_tasks_tab_panel').fireEvent('selectvyattahost', record.data.id);
  	}, this);

  	this.getView().on('itemdblclick', function(self, record, item, index, e, eOpts) {
    	this.getUserRights({ action: 'edit_in_form' }, function(userIsAdmin) {
				if (userIsAdmin) {
					this.onEditInForm();
				} else {
					Ext.Msg.show({ title: 'Access denied', msg: 'You have no rights to perform edit action!', buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR });
				}
			});
  	}, this);
  }
}
