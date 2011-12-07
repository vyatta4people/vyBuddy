class VybuddyApp < Netzke::Basepack::BorderLayoutPanel

  js_mixin :init_component

  def configuration
    super.merge(
      :name           => :vybuddy_app,
      :title          => "vyBuddy",
      :prevent_header => true,
      :layout         => :border,
      :items          => [
        :toolbox_panel.component(
          :name       => :top_panel,
          :region     => :north,
          :class_name => "TopPanel",
          :margin     => "2 2 2 2"
        ),
        :vyatta_hosts_grid.component(
          :name       => :vyatta_hosts_grid,
          :region     => :west,
          :class_name => "VyattaHostsGrid",
          :margin     => "0 0 0 2",
          :split      => true
        ),
        :display_tasks_tab_panel.component(
          :name       => :display_tasks_tab_panel,
          :region     => :center,
          :class_name => "DisplayTasksTabPanel",
          :margin     => "0 2 0 0"
        ),
        :bottom_panel.component(
          :name       => :bottom_panel,
          :region     => :south,
          :class_name => "BottomPanel",
          :margin     => "2 2 2 2"
        )
      ]
    )
  end

end