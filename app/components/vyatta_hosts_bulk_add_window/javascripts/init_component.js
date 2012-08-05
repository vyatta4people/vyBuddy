{
  initComponent: function(params) {
    this.superclass.initComponent.call(this);

    this.on('afterrender', function(self, eOpts) {
      // Define fellow components
      this.bulkAddFormPanel             = this.getComponent('vyatta_hosts_bulk_add_form');
      this.bulkAddForm                  = this.bulkAddFormPanel.getForm();
      this.bulkAddFormFields            = this.bulkAddForm.getFields();
      this.sshConnectionUsernameField   = this.bulkAddFormFields.get(0);
      this.sshConnectionPasswordField   = this.bulkAddFormFields.get(1);
      this.sshKeyPairField              = this.bulkAddFormFields.get(3);
      this.probeHostnameField           = this.bulkAddFormFields.get(4);
      this.vyattaHostGroupField         = this.bulkAddFormFields.get(5);
      this.hostsField                   = this.bulkAddFormFields.get(6);
    }, this);

    this.on('beforeshow', function(self, eOpts) {
      this.getFormComboOptions({ field: 'ssh_key_pair' }, function(data) {
        this.sshKeyPairField.getStore().loadData(data);
        this.sshKeyPairField.setValue(data[0]);
      }, this);
      this.getFormComboOptions({ field: 'vyatta_host_group' }, function(data) {
        this.vyattaHostGroupField.getStore().loadData(data);
        this.vyattaHostGroupField.setValue(data[0]);
      }, this);
    }, this);
  }
}
