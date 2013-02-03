{
  onImportExport: function() {
    if (this.importExportForm.isValid()) {
      this.importExportForm.submit({
        url: '/data/prepare_portable_objects',
        success: function(form, action) {
          var importExportWindow = Netzke.page.importExportWindow;
          //alert(action.result.data.import_file.tempfile);
          importExportWindow.loadObjectSelection(action.result.data, function(result) {
            // Load importable/exportable objects into store
            var importExportSelectionStore = Ext.create('Ext.data.ArrayStore', {
              fields: [
                { name: 'real_object_type',   type: 'string' },
                { name: 'object_type',        type: 'string' },
                { name: 'id',                 type: 'integer' },
                { name: 'name',               type: 'string' },
                { name: 'selected',           type: 'boolean' }
              ]
            });
            importExportSelectionStore.loadData(result.data);
            // Define import/export selection grid
            var importExportSelectionGrid = {
              xtype: 'grid',
              border: false,
              columns: {
                defaults: { menuDisabled: true, resizable: false, draggable: false, fixed: true },
                items: [
                  { dataIndex: 'real_object_type',  header: 'Object type (real)',   hidden: true },
                  { dataIndex: 'object_type',       header: 'Object type',          width: 130, renderer: function(value) { return('<b>'+value+'</b>'); } },
                  { dataIndex: 'id',                header: 'ID',                   hidden: true },
                  { dataIndex: 'name',              header: 'Name',                 flex: true },
                  { dataIndex: 'selected',          header: '?',                    width: 50, align: 'center', xtype: 'checkcolumn', sortable: false }
                ]
              },
              viewConfig: {
                markDirty: false
              },
              store: importExportSelectionStore,
              bbar: [
                '->',
                { xtype: 'button', text: 'Cancel', handler: function(button, e) {
                  button.up('window').close();
                } },
                { xtype: 'button', text: Ext.util.Format.capitalize(result.actionType), handler: function(button, e) {
                  var store   = button.up('grid').getStore();
                  var params  = new Array();
                  store.each(function(record) {
                    if (record.data.selected) {
                      if (!params[record.data.real_object_type]) {
                        params[record.data.real_object_type] = record.data.id.toString();
                      } else {
                        params[record.data.real_object_type] = params[record.data.real_object_type] + ',' + record.data.id.toString();
                      }
                    }
                  }, this);
                  button.up('window').close();
                  window.location = '/data/' + result.actionType + '_objects?' + Ext.Object.toQueryString(params);
                } }
              ]
            };
            var importExportSelectionWindow = Ext.create('Ext.window.Window', {
              title: '::Select objects to ' + result.actionType + '::',
              width: 500,
              height: 600,
              layout: 'fit',
              items: [importExportSelectionGrid]
            });
            // Show window with import/export selection grid
            importExportWindow.hide();
            importExportWindow.importExportForm.reset();
            importExportSelectionWindow.show();
          }, this);
        },
        failure: function(form, action) {
          Ext.Msg.alert('Failed', action.result ? action.result.message : 'No response');
        }
      });
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