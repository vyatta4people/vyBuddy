{
  initComponent: function(params) {
  	this.superclass.initComponent.call(this);

  	this.on('selectvyattahost', function(vyattaHostId) {
			Ext.Ajax.request({
		    url: '/data/get_displays_for_vyatta_host/' + vyattaHostId.toString(),
		    success: function(response) {
		    	var displays =  Ext.decode(response.responseText);
		      for (var d in displays) {
		      	var display = displays[d];
		      	Ext.fly(display.html_display_id).update(display.information);
		      }
		    }
		  });
		}, this);
  }
}
