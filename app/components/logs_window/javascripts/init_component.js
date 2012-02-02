{
  initComponent: function(params) {
  	this.superclass.initComponent.call(this);

  	this.on('show', function(self, eOpts) {
  		this.getChildNetzkeComponent('logs_grid').fireEvent('show');
    }, this);
  }
}
