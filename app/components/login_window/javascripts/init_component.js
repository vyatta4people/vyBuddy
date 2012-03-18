{
  initComponent: function(params) {
    this.superclass.initComponent.call(this);

    this.on('afterrender', function(self, eOpts) {
      this.getEl().addKeyListener(Ext.EventObject.ENTER, function() {
        this.onLogin();
      }, this);
    }, this);
  }
}
