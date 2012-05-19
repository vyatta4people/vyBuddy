function netzkeEndpointHandler(result) {
  if (result.success) {
    if (result.verbose) { Ext.Msg.show({ title: 'Action successful', msg: result.message, buttons: Ext.Msg.OK, icon: Ext.Msg.INFO }); }
  } else {
    Ext.Msg.show({ title: 'Action failed', msg: result.message, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR });
  }
}