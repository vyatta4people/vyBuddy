{
  initComponent: function(params) {
    this.superclass.initComponent.call(this);

    // Define shorter references to fellow components
    this.importExportFormPanel      = this.getComponent('import_export_form');
    this.importExportForm           = this.importExportFormPanel.getForm();
    this.objectFilterFieldset       = this.importExportFormPanel.getComponent('object_filter');
    this.objectTypesCheckboxGroup   = this.objectFilterFieldset.getComponent('object_types');
    this.actionPickerFieldset       = this.importExportFormPanel.getComponent('action_picker');
    this.actionTypeField            = this.actionPickerFieldset.getComponent('action_type');
    this.importFileField            = this.actionPickerFieldset.getComponent('import_file');

    this.on('beforeshow', function(self, eOpts) {
      this.actionTypeField.setValue('import');
    }, this);

    this.objectTypesCheckboxGroup.getComponent('task_remote_command').on('change', function(self, newValue, oldValue, eOpts) {
      if (newValue) {
        this.getComponent('task').setValue(true);
        this.getComponent('remote_command').setValue(true);
        this.getComponent('filter').setValue(true);
      }
    }, this.objectTypesCheckboxGroup);

    this.objectTypesCheckboxGroup.getComponent('task').on('change', function(self, newValue, oldValue, eOpts) {
      if (!newValue) { this.getComponent('task_remote_command').setValue(false); }
    }, this.objectTypesCheckboxGroup);

    this.objectTypesCheckboxGroup.getComponent('remote_command').on('change', function(self, newValue, oldValue, eOpts) {
      if (!newValue) { this.getComponent('task_remote_command').setValue(false); }
    }, this.objectTypesCheckboxGroup);

    this.objectTypesCheckboxGroup.getComponent('filter').on('change', function(self, newValue, oldValue, eOpts) {
      if (!newValue) { this.getComponent('task_remote_command').setValue(false); }
    }, this.objectTypesCheckboxGroup);

    this.actionTypeField.on('change', function(self, newValue, oldValue, eOpts) {
      // We need import_file field only for import, right?
      if (newValue == 'import') {
        this.importFileField.setDisabled(false);
        this.importFileField.setVisible(true);
        this.actions.importExport.setText('Import!');
      } else {
        this.importFileField.setDisabled(true);
        this.importFileField.setVisible(false);
        this.actions.importExport.setText('Export!');
      }
    }, this);

  }
}
