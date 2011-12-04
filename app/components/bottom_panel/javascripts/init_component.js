{
  initComponent: function(params) {
  	this.superclass.initComponent.call(this);

  	this.on('afterrender', function(self, eOpts) {
  		var updateBottomPanel = function() {
			  Ext.Ajax.request({
			    url: '/data/get_global_summary',
			    success: function(response) {
			    	var summary =  Ext.decode(response.responseText);
			      this.totalVyattaHosts 			= summary.total_vyatta_hosts;
			    	this.enabledVyattaHosts 		= summary.enabled_vyatta_hosts;
			      this.unreachableVyattaHosts = summary.unreachable_vyatta_hosts;
			      Ext.fly('display_total_vyatta_hosts').update(this.totalVyattaHosts.toString());
			      Ext.fly('display_enabled_vyatta_hosts').update(this.enabledVyattaHosts.toString());
			      Ext.fly('display_unreachable_vyatta_hosts').update(this.unreachableVyattaHosts.toString());
			    }
			  });
  		}
			Ext.TaskManager.start({ run: updateBottomPanel, interval: 5000 });
  	}, this);
  }
}
