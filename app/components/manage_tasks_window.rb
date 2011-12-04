class ManageTasksWindow < Netzke::Basepack::Window

  def configuration
    super.merge(
      :name             => :manage_tasks_window,
      :title            => "::Tasks::",
      :layout           => :border,
      :width            => 1200,
      :height           => 500,
      :y                => 50,
      :modal            => true,
      :close_action     => :hide,
      :resizable        => false,
      :items            => [
        :tasks_grid.component(
          :name       => :tasks_grid,
          :region     => :west,
          :class_name => "TasksGrid"
        ),
        :task_remote_commands_grid.component(
          :name       => :task_remote_commands_grid,
          :region     => :center,
          :class_name => "TaskRemoteCommandsGrid"
        ),
        :tasks_side_tab_panel.component(
          :name       => :tasks_side_tab_panel,
          :region     => :east,
          :class_name => "TasksSideTabPanel"
        )
      ]
    )
  end

end