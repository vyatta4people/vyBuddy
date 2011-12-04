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
          :class_name => "TopPanel"
        ),
        :vyatta_hosts_grid.component(
          :name       => :vyatta_hosts_grid,
          :region     => :west,
          :class_name => "VyattaHostsGrid"
        ),
        :display_tasks_tab_panel.component(
          :name       => :display_tasks_tab_panel,
          :region     => :center,
          :class_name => "DisplayTasksTabPanel"
        ),
        :bottom_panel.component(
          :name       => :bottom_panel,
          :region     => :south,
          :class_name => "BottomPanel"
        )
      ]
    )
  end

end