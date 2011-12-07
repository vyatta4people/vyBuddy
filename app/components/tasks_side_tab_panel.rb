class TasksSideTabPanel < Netzke::Basepack::TabPanel

  def configuration
    super.merge(
      :name             => :tasks_side_tab_panel,
      :title            => "Side panel",
      :prevent_header   => true,
      :width            => 400,
      :border           => true,
      :frame            => false,
      :active_tab       => 1,
      :items            => [
        :task_groups_grid.component(
          :name       => :task_groups_grid,
          :class_name => "TaskGroupsGrid"
        ),
        :remote_commands_grid.component(
          :name       => :remote_commands_grid,
          :class_name => "RemoteCommandsGrid"
        ),
        :filters_grid.component(
          :name       => :filters_grid,
          :class_name => "FiltersGrid"
        )
      ]
    )
  end

end