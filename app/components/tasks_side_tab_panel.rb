class TasksSideTabPanel < Netzke::Base

  js_configure do |c|
    c.extend = "Ext.tab.Panel"
  end

  def configure(c)
    super
    c.name = :tasks_side_tab_panel
    c.title = "Toolbox"
    c.prevent_header = false
    c.width = 250
    c.border = true
    c.frame = false
    c.active_tab = 0
    c.items = [
        {
          :name       => :groups_tab_panel,
          :title      => "Groups",
          :class_name => "Netzke::Basepack::TabPanel",
          :active_tab => 0,
          :items      => [
            {
              :netzke_component       => :vyatta_host_groups_grid,
              :class_name => "VyattaHostGroupsGrid"
            },
            {
              :netzke_component       => :task_groups_grid,
              :class_name => "TaskGroupsGrid"
            }
          ]
        }, {
          :name       => :commands_tab_panel,
          :title      => "Commands",
          :class_name => "Netzke::Basepack::TabPanel",
          :active_tab => 0,
          :items      => [
            {
              :netzke_component       => :remote_commands_grid,
              :class_name => "RemoteCommandsGrid"
            },
            {
              :netzke_component       => :filters_grid,
              :class_name => "FiltersGrid"
            }
          ]
        }
      ]
  end

  component :vyatta_host_groups_grid do |c|
    c.klass = VyattaHostGroupsGrid
  end

  component :task_groups_grid do |c|
    c.klass = TaskGroupsGrid
  end

  component :remote_commands_grid do |c|
    c.klass = RemoteCommandsGrid
  end

  component :filters_grid do |c|
    c.klass = FiltersGrid
  end

end
