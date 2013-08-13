{
  initComponent: function(params) {
    this.superclass.initComponent.call(this);

    this.taskExecutionIsCancelled = false;
    this.taskVariableParameters   = {};

    this.on('afterrender', function(self, eOpts) {
      this.loadingMask = new Ext.LoadMask(Ext.getBody(), { msg: "Please wait for task execution..." });
      Ext.Ajax.request({
        url: '/data/get_tasks',
        success: function(response) {
          var displayTasksTabPanel    = Netzke.page.vybuddyApp.netzkeGetComponent('display_tasks_tab_panel');
          displayTasksTabPanel.tasks  = Ext.decode(response.responseText);
          for (var t in displayTasksTabPanel.tasks) {
            var task              = displayTasksTabPanel.tasks[t];
            var taskButtonDiv     = Ext.get(task.html_button_container_id);
            if (taskButtonDiv) { 
              Ext.create('Ext.Button', {
                id: task.html_execute_button_id,
                taskId: task.id,
                taskIsWriter: task.is_writer,
                taskContainsVariables: task.contains_variables,
                taskVariables: task.variables,
                text: 'Execute now',
                tooltip: 'Just do it!',
                width: 132,
                height: 42,
                iconCls: 'task-execute-button-icon', 
                disabled: true,
                renderTo: taskButtonDiv,
                handler: function(button, e) {
                  var vyattaHostsGrid = Netzke.page.vybuddyApp.netzkeGetComponent('vyatta_hosts_grid');
                  if (button.taskContainsVariables) {
                    displayTasksTabPanel.setTaskVariablesAndExecuteTask(vyattaHostsGrid.selectedVyattaHostId, button.taskId, button.taskVariables);
                  } else {
                    displayTasksTabPanel.simplyExecuteTask(vyattaHostsGrid.selectedVyattaHostId, button.taskId);
                  }
                }
              });
              Ext.create('Ext.Button', {
                id: task.html_comment_button_id,
                taskId: task.id,
                taskCommentContainerId: task.html_comment_container_id,
                text: ' ',
                tooltip: 'View comment?..',
                width: 42,
                height: 42,
                iconCls: 'task-comment-button-icon',
                margin: '0 0 0 10',
                renderTo: taskButtonDiv,
                handler: function(button, e) {
                  displayTasksTabPanel.getTaskComment({ task_id: button.taskId }, function(result) {
                    var commentDiv = Ext.get(button.taskCommentContainerId);
                    if (commentDiv.isVisible()) {
                      var margin = commentDiv.getHeight() + 10;
                      commentDiv.setStyle('margin-bottom', '-' + margin.toString() + 'px');
                      commentDiv.hide(true);
                    } else {
                      commentDiv.update(result.comment);
                      commentDiv.setStyle('margin-bottom', '10px');
                      commentDiv.show(true);
                    }
                  }, this);
                }
              });
              var commentDiv = Ext.get(task.html_comment_container_id);
              commentDiv.setStyle('margin-bottom', '-32px');
              commentDiv.hide();
            }
          }
        }
      });      
    }, this);

    this.on('executetask', function(vyattaHostId, taskId, taskVariableParameters) {
      this.executeTask({ vyatta_host_id: vyattaHostId, task_id: taskId, task_variable_parameters: taskVariableParameters }, function(result) {
        this.fireEvent('selectvyattahost', vyattaHostId);
        this.loadingMask.hide();
        netzkeEndpointHandler(result);
      }, this);
    }, this);

    this.on('selectvyattahost', function(vyattaHostId) {
      this.selectedVyattaHostId = vyattaHostId;
      Ext.Ajax.request({
        url: '/data/get_displays/' + vyattaHostId.toString(),
        success: function(response) {
          var displays                    = Ext.decode(response.responseText);
          var unitedInformationData       = '';
          var previousUnitedInformationId = '';
          for (var d in displays) {
            var display       = displays[d];
            if (!display.show_as_one) {
              var displayData = '<div class="display-header">' +
                display.remote_command_mode + ' :: ' + display.remote_command + ' | ' + display.filter +
                '</div><pre><div class="display-information">' + display.information +
                '</div></pre><div class="display-footer">Changed at: ' + display.updated_at + '</div>';
            } else {
              var displayData = '<div class="display-united">' + 
                display.remote_command_mode + ' :: ' + display.remote_command + '</div>';
            }
            var displayDiv    = Ext.get(display.html_display_id);
            if (displayDiv) { displayDiv.update(displayData); }
            if (display.show_as_one) {
              var unitedInformationDiv = Ext.get(display.html_united_information_id);
              if (unitedInformationDiv) {
                if (display.html_united_information_id == previousUnitedInformationId) {
                  unitedInformationData = unitedInformationDiv.dom.innerHTML + display.information;
                } else {
                  unitedInformationData = display.information;
                }
                unitedInformationDiv.update(unitedInformationData);
              }
              previousUnitedInformationId = display.html_united_information_id;
            }
          }
        }
      });
    }, this);
  }
}
