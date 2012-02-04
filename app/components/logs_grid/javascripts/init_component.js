{
  initComponent: function(params) {
  	this.superclass.initComponent.call(this);

		this.justLoaded = false;

  	this.on('show', function(self, eOpts) {
  		this.filterFromDate.reset();
  		this.filterToDate.reset();
  		this.filterSilentLog.reset();
  		this.filterSearchMessage.reset();

      this.actions.downloadLogs.setDisabled(true);

  		this.justLoaded = true;
			this.getStore().getProxy().extraParams.query = null;
			this.getStore().sort('created_at', 'ASC'); // NB! Triggers 'load' event!
    }, this);

    this.getStore().on('load', function(self, records, successful, operation, eOpts) {
  		if ((records) && (records.length > 0)) {
  	    this.getSelectionModel().select(0);
  	    this.getView().focus();
  	    if (this.justLoaded) {
  	    	this.justLoaded = false;
  	    	var pageCount 	= this.getStore().getPageFromRecordIndex(this.getStore().getTotalCount()-1);
  	   		this.getStore().loadPage(pageCount); // NB! Triggers 'load' event!
  	   	}
  		}
  	}, this);

  	this.on('afterrender', function(self, eOpts) {
  		this.filterTbar 					= this.getDockedItems('toolbar[dock="top"]')[0];
  		this.filterFromDate				= this.filterTbar.getComponent('from_date');
  		this.filterToDate					= this.filterTbar.getComponent('to_date');
  		this.filterSilentLog			= this.filterTbar.getComponent('silent_log');
  		this.filterSearchMessage	= this.filterTbar.getComponent('search_message');
    }, this);
  }
}
