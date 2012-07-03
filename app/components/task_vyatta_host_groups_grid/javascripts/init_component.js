{
  initComponent: function(params) {
    this.superclass.initComponent.call(this);

    this.on('afterrender', function(self, eOpts) {
      // Define fellow components
      this.tasksGrid            = Netzke.page.manageTasksWindow.getChildNetzkeComponent('tasks_grid');
      this.vyattaHostGroupsGrid = Netzke.page.manageTasksWindow.getChildNetzkeComponent('tasks_side_tab_panel').getChildNetzkeComponent('groups_tab_panel').getChildNetzkeComponent('vyatta_host_groups_grid');
      // Setup drop target for Vyatta host groups
      var dropTargetEl   = this.body.dom;
      var dropTarget     = Ext.create('Ext.dd.DropTarget', dropTargetEl, {
        ddGroup: 'vyatta_host_groups_dd_group',
        notifyEnter: function(ddSource, e, data) {
          var targetGrid = Netzke.page.manageTasksWindow.getChildNetzkeComponent('task_details_tab_panel').getChildNetzkeComponent('task_vyatta_host_groups_grid'); // Yes, we need to find ourselves here :)
          if (ddSource.id == 'manage_tasks_window__tasks_side_tab_panel__groups_tab_panel__vyatta_host_groups_grid-body') {
            targetGrid.body.stopAnimation();
            targetGrid.body.highlight();
          }
        }
      });
    }, this);

    this.on('selecttask', function(taskId, taskName) {
      var store = this.getStore();
      var proxy = store.getProxy();
      proxy.extraParams.query = Ext.encode([ [ { attr: "task_id", value: taskId, operator: "eq" } ] ]);
      store.load();
    }, this);

    this.getView().on('beforedrop', function(node, data, dropRec, dropPosition) {
      if (data.view.ownerCt.id != 'manage_tasks_window__tasks_side_tab_panel__groups_tab_panel__vyatta_host_groups_grid') {
        this.getStore().load();
        return(false); 
      }
    }, this);

    this.getView().on('drop', function(node, data, dropRec, dropPosition) {
      var taskId            = this.tasksGrid.selectedTaskId;
      var vyattaHostGroupId = data.records[0].data.id;
      this.addTaskVyattaHostGroup({ task_id: taskId, vyatta_host_group_id: vyattaHostGroupId }, function(result) {
        netzkeEndpointHandler(result);
        this.getStore().load();
        this.vyattaHostGroupsGrid.getStore().load();
      }, this);
    }, this);
  }
}