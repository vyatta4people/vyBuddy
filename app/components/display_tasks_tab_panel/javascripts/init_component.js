{
  initComponent: function(params) {
    this.superclass.initComponent.call(this);

    this.on('selectvyattahost', function(vyattaHostId) {
      Ext.Ajax.request({
        url: '/data/get_displays/' + vyattaHostId.toString(),
        success: function(response) {
          var displays = Ext.decode(response.responseText);
          for (var d in displays) {
            var display     = displays[d];
            var displayDiv   = Ext.get(display.html_display_id);
            if (displayDiv) { displayDiv.update(display.information); }
          }
        }
      });
    }, this);
  }
}
