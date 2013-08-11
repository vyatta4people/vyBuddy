{
  initComponent: function(params) {
    this.superclass.initComponent.call(this);

    this.on('show', function(self, eOpts) {
      this.netzkeGetComponent('logs_grid').fireEvent('show');
    }, this);
  }
}
