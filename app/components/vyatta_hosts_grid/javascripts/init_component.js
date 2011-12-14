{
  initComponent: function(params) {
  	this.superclass.initComponent.call(this);

  	this.on('afterrender', function(self, eOpts) {
  		var updateVyattaHostsGrid = function() { self.store.load(); }
			Ext.TaskManager.start({ run: updateVyattaHostsGrid, interval: 500000 });
  	}, this);

  	this.store.on('load', function(self, records, successful, operation, eOpts) {
  		this.getSelectionModel().select(this.selectedVyattaHostsGridRow);
  	}, this);

  	this.on('select', function(self, record, index, eOpts) {
  		this.selectedVyattaHostId 				= record.data.id;
  		this.selectedVyattaHostsGridRow 	= index;
  		Netzke.page.vybuddyApp.getChildNetzkeComponent('display_tasks_tab_panel').fireEvent('selectvyattahost', this.selectedVyattaHostId);
  	}, this);
  }
}
