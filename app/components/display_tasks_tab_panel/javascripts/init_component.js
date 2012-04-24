{
  initComponent: function(params) {
    this.superclass.initComponent.call(this);

    this.on('selectvyattahost', function(vyattaHostId) {
      Ext.Ajax.request({
        url: '/data/get_displays/' + vyattaHostId.toString(),
        success: function(response) {
          var displays = Ext.decode(response.responseText);
          for (var d in displays) {
            var display       = displays[d];
            var displayData   = '<div class="display-header">' + 
            display.remote_command_mode + ' :: '+ display.remote_command + ' | ' + display.filter +
              '</div><pre><div class="display-information">' + display.information + 
              '</div></pre><div class="display-footer">Last updated at: ' + display.updated_at + '</div>';
            var displayDiv    = Ext.get(display.html_display_id);
            if (displayDiv) { displayDiv.update(displayData); }
          }
        }
      });
    }, this);
  }
}
