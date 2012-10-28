class TasksSideTabPanel < Netzke::Basepack::TabPanel

  def configuration
    super.merge(
      :name             => :tasks_side_tab_panel,
      :title            => "Toolbox",
      :prevent_header   => false,
      :width            => 250,
      :border           => true,
      :frame            => false,
      :active_tab       => 0,
      :items            => [
        {
          :name       => :groups_tab_panel, 
          :title      => "Groups",
          :class_name => "Netzke::Basepack::TabPanel",
          :active_tab => 0,
          :items      => [
            :vyatta_host_groups_grid.component(
              :name       => :vyatta_host_groups_grid,
              :class_name => "VyattaHostGroupsGrid"
            ),
            :task_groups_grid.component(
              :name       => :task_groups_grid,
              :class_name => "TaskGroupsGrid"
            )            
          ]
        }, {
          :name       => :commands_tab_panel, 
          :title      => "Commands",
          :class_name => "Netzke::Basepack::TabPanel",
          :active_tab => 0,
          :items      => [
            :remote_commands_grid.component(
              :name       => :remote_commands_grid,
              :class_name => "RemoteCommandsGrid"
            ),
            :filters_grid.component(
              :name       => :filters_grid,
              :class_name => "FiltersGrid"
            )
          ]
        }
      ]
    )
  end

end