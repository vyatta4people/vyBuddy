{
  onSearchLogs: function() {
		var store 					= this.getStore();
		var proxy						= store.getProxy();
		var fromDate 				= this.filterFromDate.getValue();
		var toDate 					= this.filterToDate.getValue(); 	
		var silentLog				= this.filterSilentLog.getValue();
		var searchMessage 	= this.filterSearchMessage.getValue();
		
		if (fromDate > toDate) { 
			Ext.Msg.show({ 
				title: 'Error', 
				msg: '"From" date bigger than "To" date!', 
				buttons: Ext.Msg.OK, 
				icon: Ext.Msg.ERROR,
				scope: this,
				fn: function() { this.fireEvent('show'); }
			});
		}
		
		fromDate.setDate(fromDate.getDate()-1);
		toDate.setDate(toDate.getDate()+1);
		
		var searchFilter 	= new Array; var i = 0;
		searchFilter[i] 	= { attr: 'created_date', value: fromDate, operator: 'gt' }; i++;
		searchFilter[i] 	= { attr: 'created_date', value: toDate, 	 operator: 'lt' }; i++;
		if (silentLog) { searchFilter[i] = { attr: 'is_verbose', value: false, operator: 'eq' },  i++; }
		if (searchMessage.length > 0) { searchFilter[i] = { attr: 'message', value: searchMessage, operator: 'contains' }; }

  	proxy.extraParams.query = Ext.encode([ searchFilter ]);
		store.loadPage(1); // NB! Triggers 'load' event!
		this.actions.downloadLogs.setDisabled(false);
  },

  onClearSearchFilter: function() {
  	this.fireEvent('show');
  },

  onDownloadLogs: function() {
  	var urlRoot 	= '/data/export_logs';
    var	urlParams = Ext.Object.toQueryString({ 
    	from_date: 			this.filterFromDate.getValue(),
    	to_date: 				this.filterToDate.getValue(),
    	silent_log: 		this.filterSilentLog.getValue(),
    	search_message: this.filterSearchMessage.getValue()
   	});
		window.open(urlRoot + '?' + urlParams);
  }
}
