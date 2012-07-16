{
  afterDelete: function(data) {
    this.reorderRecords({ selected_task_group_id: this.selectedTaskGroupId }, function (result) { 
      if (!result.success) { Ext.Msg.show({ title: 'Re-Order failed', msg: result.message, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR }); }
    });
    this.getStore().load();
  },

  initTaskDetailsTabPanel: function() {
    this.taskDetailsTabPanel.on('tabchange', function(self, newCard, oldCard, eOpts) {
      var panelId = newCard.getId();
      if (panelId == 'manage_tasks_window__task_details_tab_panel__task_remote_commands_grid') {
        this.tasksSideTabPanel.setActiveTab(1);
        this.commandsTabPanel.setActiveTab(0);
        newCard.body.highlight('fff391', {easing: 'ease'});
        this.commandsTabPanel.getActiveTab().body.highlight('fff391', {easing: 'ease'});
      }
      if (panelId == 'manage_tasks_window__task_details_tab_panel__task_vyatta_host_groups_grid') {
        this.tasksSideTabPanel.setActiveTab(0);
        this.groupsTabPanel.setActiveTab(0);
        newCard.body.highlight('b9ffb6', {easing: 'ease'});
        this.groupsTabPanel.getActiveTab().body.highlight('b9ffb6', {easing: 'ease'});
      }
    }, this);
  }
}
