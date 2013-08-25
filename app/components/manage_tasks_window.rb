class ManageTasksWindow < Netzke::Basepack::Window

  js_configure do |c|
    c.mixin :main
  end

  def configure(c)
    super
    c.name             = :manage_tasks_window
    c.title            = "::Tasks::"
    c.layout           = :border
    c.width            = 1200
    c.height           = 520
    c.y                = 50
    c.modal            = true
    c.close_action     = :hide
    c.resizable        = false
    c.items            = [
      {
        :netzke_component => :tasks_grid,
        :region     => :center,
        :klass => "TasksGrid",

    :style      => { :border_right => CSS_BORDER_STYLE },
        :margin     => "0 2 0 0"
      },
=begin
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
          {
            :name       => :task_remote_commands_grid,
            :class_name => "TaskRemoteCommandsGrid",
          }, {
            :name       => :task_vyatta_host_groups_grid,
            :class_name => "TaskVyattaHostGroupsGrid",
          }
        ]
      },
      {
        :name       => :tasks_side_tab_panel,
        :region     => :east,
        :class_name => "TasksSideTabPanel",
        :margin     => "2 2 2 2"
      }
=end
    ]
  end

  component :tasks_grid do |c|
    c.klass = TasksGrid
  end

=begin

  component :task_details_tab_panel do |c|
    c.klass = TaskDetailsTabPanel
  end

  component :task_remote_commands_grid do |c|
    c.klass = TaskRemoteCommandsGrid
  end

  component :task_vyatta_host_groups_grid do |c|
    c.klass = TaskVyattaHostGroupsGrid
  end

  component :tasks_side_tab_panel do |c|
    c.klass = TasksSideTabPanel
  end
=end

end
