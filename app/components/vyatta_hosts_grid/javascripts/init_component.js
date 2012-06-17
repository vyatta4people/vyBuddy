{
  initComponent: function(params) {
    this.superclass.initComponent.call(this);

    this.selectedVyattaHostId         = 0;
    this.selectedVyattaHostGroupId    = 0;
    this.selectedRow                  = 0;
    this.isSelectedVyattaHostOperable = false

    this.on('afterrender', function(self, eOpts) {
      var updateVyattaHostsGrid = function() { self.store.load(); }
      Ext.TaskManager.start({ run: updateVyattaHostsGrid, interval: 5000 });
      // Declare shorthand to fellow component
      this.displayTasksTabPanel = Netzke.page.vybuddyApp.getChildNetzkeComponent('display_tasks_tab_panel');
    }, this);

    this.getStore().on('load', function(self, records, successful, operation, eOpts) {
      if ((records) && (records.length > 0)) { 
        this.getSelectionModel().select(this.selectedRow);
      }
    }, this);

    this.on('select', function(self, record, index, eOpts) {
      this.selectedVyattaHostId         = record.data.id;
      this.selectedVyattaHostGroupId    = record.data.vyatta_host_group__name;
      this.selectedRow                  = index;
      this.isSelectedVyattaHostOperable = record.data.is_enabled && record.data.is_daemon_running && record.data.is_reachable;
      this.actions.executeAllTasks.setDisabled(!this.isSelectedVyattaHostOperable);
      this.actions.executeOnDemandTasks.setDisabled(!this.isSelectedVyattaHostOperable);
      this.actions.executeBackgroundTasks.setDisabled(!this.isSelectedVyattaHostOperable);
      var containerColor = shadowGreen;
      if (!this.isSelectedVyattaHostOperable) {
        if (!record.data.is_reachable && record.data.is_daemon_running) {
          containerColor = shadowRed;
        } else if (!record.data.is_enabled) {
          containerColor = shadowGrey;
        } else {
          containerColor = shadowViolet;
        }
      }
      for (var t in this.displayTasksTabPanel.tasks) {
        var task              = this.displayTasksTabPanel.tasks[t];
        var containerDiv      = Ext.get(task.html_container_id);
        var taskExecuteButton = Ext.getCmp(task.html_execute_button_id);
        var taskCommentButton = Ext.getCmp(task.html_comment_button_id);
        containerDiv.setStyle('background-color', containerColor);
        taskExecuteButton.setDisabled(!this.isSelectedVyattaHostOperable);
        taskCommentButton.setDisabled(task.is_comment_empty);
      }
      this.displayTasksTabPanel.fireEvent('selectvyattahost', this.selectedVyattaHostId);
    }, this);

    this.getView().on('drop', function(node, data, dropRec, dropPosition) {
      this.reorganizeWithPersistentOrder({ moved_record_id: data.records[0].data.id, replaced_record_id: dropRec.data.id, position: dropPosition }, function(result) {
        if (result.success) {
          this.getStore().load();
        } else {
          Ext.Msg.show({ title: 'Vyatta host re-order failed', msg: result.message, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR });
        }
      });
    }, this);

    this.getView().on('itemdblclick', function(self, record, item, index, e, eOpts) {
      this.getUserRights({ action: 'edit_in_form' }, function(userIsAdmin) {
        if (userIsAdmin) {
          this.onEditInForm();
        } else {
          Ext.Msg.show({ title: 'Access denied', msg: 'You have no rights to perform edit action!', buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR });
        }
      });
    }, this);
  }
}
