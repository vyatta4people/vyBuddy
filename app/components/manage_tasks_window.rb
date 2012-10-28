class ManageTasksWindow < Netzke::Basepack::Window

  js_mixin :init_component

  def configuration
    super.merge(
      :name             => :manage_tasks_window,
      :title            => "::Tasks::",
      :layout           => :border,
      :width            => 1200,
      :height           => 520,
      :y                => 50,
      :modal            => true,
      :close_action     => :hide,
      :resizable        => false,
      :items            => [
        :tasks_grid.component(
          :name       => :tasks_grid,
          :region     => :west,
          :class_name => "TasksGrid",
          :style      => { :border_right => CSS_BORDER_STYLE },
          :margin     => "0 2 0 0"
        ), 
        {
          :name             => :task_details_tab_panel,
          :region           => :center,
          :title            => "Task details",
          :prevent_header   => false,
          :border           => true,
          :margin           => "2 0 2 0",
          :class_name       => "Netzke::Basepack::TabPanel",
          :active_tab       => 0,
          :items => [
            :task_remote_commands_grid.component(
              :name       => :task_remote_commands_grid,
              :class_name => "TaskRemoteCommandsGrid",
            ),
            :task_vyatta_host_groups_grid.component(
              :name       => :task_vyatta_host_groups_grid,
              :class_name => "TaskVyattaHostGroupsGrid",
            )            
          ]
        },
        :tasks_side_tab_panel.component(
          :name       => :tasks_side_tab_panel,
          :region     => :east,
          :class_name => "TasksSideTabPanel",
          :margin     => "2 2 2 2"
        )
      ]
    )
  end

end