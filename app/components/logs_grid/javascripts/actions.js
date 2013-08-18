{
  onSearchLogs: function() {
    var fromDate          = this.filterFromDate.getValue();
    var toDate            = this.filterToDate.getValue();
    var silentLog         = this.filterSilentLog.getValue();
    var searchMessage     = this.filterSearchMessage.getValue();
    
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

    this.searchLogs({from_date: fromDate, to_date: toDate, silent_log: silentLog, search_message: searchMessage},
      function() { this.getStore().loadPage(1); this.actions.downloadLogs.setDisabled(false); }
    );
  },

  onClearSearchFilter: function() {
    this.fireEvent('show');
  },

  onDownloadLogs: function() {
    var urlRoot   = '/data/export_logs';
    var urlParams = Ext.Object.toQueryString({ 
      from_date:        this.filterFromDate.getValue(),
      to_date:          this.filterToDate.getValue(),
      silent_log:       this.filterSilentLog.getValue(),
      search_message:   this.filterSearchMessage.getValue()
     });
    window.open(urlRoot + '?' + urlParams);
  }
}
