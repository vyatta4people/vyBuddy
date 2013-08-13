{
  onLogin: function() {
    var loginForm = Ext.ComponentManager.get('login_form').getForm();
    if (loginForm.isValid()) {
      this.login(loginForm.getFieldValues(), function(success) {
        if (success) {
          window.location = '/';
        } else {
          Ext.Msg.show({ title: 'Login failed', msg: 'Invalid username or password!', buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR });
        }
      }, this);
    } else { Ext.Msg.show({ title: 'Form fields not filled', msg: 'Please fill in all login form fields!', buttons: Ext.Msg.OK, icon: Ext.Msg.WARNING }); }
  }
}
