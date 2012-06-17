class ManageTasksWindow < Netzke::Basepack::Window

  js_mixin :init_component

  def configuration
    super.merge(
      :name             => :manage_tasks_window,
      :title            => "::Tasks::",
      :layout           => :border,
      :width            => 1100,
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
        :task_remote_commands_grid.component(
          :name       => :task_remote_commands_grid,
          :region     => :center,
          :class_name => "TaskRemoteCommandsGrid",
          :style      => { :border_left => CSS_BORDER_STYLE, :border_right => CSS_BORDER_STYLE }
        ),
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