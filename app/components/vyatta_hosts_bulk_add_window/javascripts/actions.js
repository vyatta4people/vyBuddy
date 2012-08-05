{
  onBulkAdd: function() {
    if (this.bulkAddForm.isValid()) {      
      this.bulkAddMask = new Ext.LoadMask(Ext.getBody(), { msg: "Adding hosts... Please wait!" });
      this.bulkAddMask.show();
      this.bulkAddVyattaHosts(this.bulkAddForm.getFieldValues(), function(results) {
        // Create store for result data coming from server and load it
        var resultStore = Ext.create('Ext.data.ArrayStore', {
          fields: [
            { name: 'hostname', type: 'string' },
            { name: 'success',  type: 'boolean' },
            { name: 'message',  type: 'string' }
          ]
        });
        resultStore.loadData(results);
        // Summarize result successes & failures
        var successCount = 0;
        var failureCount = 0;
        resultStore.each(function() {
          if (this.data.success) { successCount++; } else { failureCount++; }
        });
        // Define grid to show results in
        var resultGrid = {
          xtype: 'grid',
          border: false,
          columns: {
            defaults: { menuDisabled: true, resizable: false, draggable: false, fixed: true },
            items: [
              { dataIndex: 'hostname',  header: 'Hostname', width: 180 },
              { dataIndex: 'success',   header: 'Success?', width: 100, align: 'center', renderer: booleanRenderer },
              { dataIndex: 'message',   header: 'Message',  flex: true }
            ]
         },
          store: resultStore
        }
        // Hide form window and show cool result grid in a new window
        this.bulkAddMask.hide();
        this.hide();
        this.bulkAddForm.reset();
        Ext.create('Ext.window.Window', {
          title: '::Bulk add report:: (Success: ' + successCount.toString() + ' / Failure: ' + failureCount.toString() + ')',
          width: 700,
          height: 500,
          layout: 'fit',
          items: [resultGrid]
        }).show();
      }, this)
    } else {
      Ext.Msg.show({ 
        title: 'Form fields not filled', 
        msg: 'Please fill in all required form fields!', 
        buttons: Ext.Msg.OK, 
        icon: Ext.Msg.WARNING 
      });
    }
  }
}