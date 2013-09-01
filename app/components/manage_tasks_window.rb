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
        :netzke_component   => :tasks_grid,
        :region             => :west,
        :style              => { :border_right => CSS_BORDER_STYLE },
        :margin             => "0 2 0 0"
      }, {
        :netzke_component   => :task_details_tab_panel,
        :region             => :center,
        :title              => "Task details",
        :items              => [
          {
            :netzke_component   => :task_remote_commands_grid
          }, {
            :netzke_component   => :task_vyatta_host_groups_grid,
          }
        ]
      }, {
        :netzke_component => :tasks_side_tab_panel,
        :region           => :east
      }
    ]
  end

  component :tasks_grid do |c|
    c.klass = TasksGrid
  end

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

end
