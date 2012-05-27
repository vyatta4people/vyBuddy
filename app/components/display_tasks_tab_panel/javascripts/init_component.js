{
  initComponent: function(params) {
    this.superclass.initComponent.call(this);

    this.on('afterrender', function(self, eOpts) {
      Ext.Ajax.request({
        url: '/data/get_tasks',
        success: function(response) {
          var displayTasksTabPanel    = Netzke.page.vybuddyApp.getChildNetzkeComponent('display_tasks_tab_panel');
          displayTasksTabPanel.tasks  = Ext.decode(response.responseText);
          for (var t in displayTasksTabPanel.tasks) {
            var task              = displayTasksTabPanel.tasks[t];
            var taskButtonDiv     = Ext.get(task.html_button_container_id);
            if (taskButtonDiv) { 
              Ext.create('Ext.Button', {
                id: task.html_execute_button_id,
                taskId: task.id,
                text: 'Execute now',
                tooltip: 'Just do it!',
                width: 132,
                height: 42,
                iconCls: 'task-button-icon', 
                renderTo: taskButtonDiv,
                handler: function(button, e) {
                  var vyattaHostsGrid       = Netzke.page.vybuddyApp.getChildNetzkeComponent('vyatta_hosts_grid');
                  var mask                  = new Ext.LoadMask(Ext.getBody(), { msg: "Please wait for task execution..." });
                  mask.show();
                  displayTasksTabPanel.executeTask({ vyatta_host_id: vyattaHostsGrid.selectedVyattaHostId, task_id: button.taskId }, function(result) {
                    displayTasksTabPanel.fireEvent('selectvyattahost', vyattaHostsGrid.selectedVyattaHostId);
                    mask.hide();
                    netzkeEndpointHandler(result);
                  }, this);
                }
              });
            }
          }
        }
      });      
    }, this);

    this.on('selectvyattahost', function(vyattaHostId) {
      this.selectedVyattaHostId = vyattaHostId;
      Ext.Ajax.request({
        url: '/data/get_displays/' + vyattaHostId.toString(),
        success: function(response) {
          var displays = Ext.decode(response.responseText);
          for (var d in displays) {
            var display       = displays[d];
            var displayData   = '<div class="display-header">' + 
            display.remote_command_mode + ' :: '+ display.remote_command + ' | ' + display.filter +
              '</div><pre><div class="display-information">' + display.information + 
              '</div></pre><div class="display-footer">Changed at: ' + display.updated_at + '</div>';
            var displayDiv    = Ext.get(display.html_display_id);
            if (displayDiv) { displayDiv.update(displayData); }
          }
        }
      });
    }, this);
  }
}
