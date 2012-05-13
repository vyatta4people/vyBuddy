{
  initComponent: function(params) {
    this.superclass.initComponent.call(this);

    this.getView().on('itemdblclick', function(self, record, item, index, e, eOpts) {
      this.onEditInForm();
    }, this);
  }
}