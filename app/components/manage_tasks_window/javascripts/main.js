{
  initComponent: function(params) {
    this.superclass.initComponent.call(this);

    this.on('beforeclose', function(self, eOpts) {
      window.location.reload(); // SHAME ON ME!
    }, this);
  }
}
