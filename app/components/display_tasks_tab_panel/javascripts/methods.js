{
  setTaskVariablesAndExecuteTask: function(vyattaHostId, taskId, taskVariables) {
    var taskVariableFormItems = new Array;
    for (var i = 0; i < taskVariables.length; i++) {
      taskVariableFormItems.push({fieldLabel: taskVariables[i], name: taskVariables[i]})
    }
    var taskVariableForm = Ext.create('Ext.form.Panel', {
      bodyPadding: 5,
      defaults: { anchor: '100%', allowBlank: false },
      defaultType: 'textfield',
      items: taskVariableFormItems,
      buttons: [{
        text: 'Cancel',
        handler: function() {
          this.up('window').hide();
          this.up('form').getForm().reset();
        }
      }, {
        text: 'Execute!',
        formBind: true,
        disabled: true,
        handler: function() {
          var taskVariableParameters = this.up('form').getForm().getFieldValues();
          this.up('window').hide();
          this.up('form').getForm().reset();
          var displayTasksTabPanel = Netzke.page.vybuddyApp.netzkeGetComponent('display_tasks_tab_panel');
          displayTasksTabPanel.loadingMask.show();
          displayTasksTabPanel.fireEvent('executetask', vyattaHostId, taskId, taskVariableParameters);
        }
    }],
    });
    var taskVariableWindow = Ext.create('Ext.Window', {
      title: 'Set task variables before execution...',
      width: 500,
      closable: false,
      modal: true,
      layout: 'fit',
      items: [taskVariableForm]
    });
    taskVariableWindow.show();
  },
  
  simplyExecuteTask: function(vyattaHostId, taskId) {
    this.loadingMask.show();
    this.fireEvent('executetask', vyattaHostId, taskId);
  }
}
