{
  initComponent: function(params) {
    this.superclass.initComponent.call(this);

    Ext.EventManager.onWindowResize(function() {
      this.setWidth(window.innerWidth);
      this.setHeight(window.innerHeight);
    }, this);

    this.on('afterrender', function(self, eOpts) {
      Netzke.directProvider.timeout = defaultDirectTimeout;
      self.setHeight(window.innerHeight);
    }, this);
  }
}
