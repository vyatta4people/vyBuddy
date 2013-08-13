class VybuddyApp < Netzke::Basepack::Viewport

  js_configure do |c|
    c.mixin :main
    c.layout = :border
  end

  def configure(c)
    super
    c.name           = :vybuddy_app
    c.title          = "vyBuddy"
    c.prevent_header = true
    c.body_style     = {"background-color" => "#e4ebef"}
    c.items          = [ {
      netzke_component: :top_panel,
      region:           :north,
      margin:            "5 5 5 5"
    }, {
      netzke_component: :vyatta_hosts_grid,
      region:           :west,
      margin:           "0 5 0 5",
      split:            true
    }, {
      netzke_component: :display_tasks_tab_panel,
      region:           :center,
      margin:           "0 5 0 0",
      split:            true
    }, {
      netzke_component: :bottom_panel,
      region:           :south,
      margin:           "5 5 5 5"
    } ]
  end

  component :top_panel do |c|
    c.klass = TopPanel
  end

  component :vyatta_hosts_grid do |c|
    c.klass = VyattaHostsGrid
  end

  component :display_tasks_tab_panel do |c|
    c.klass = DisplayTasksTabPanel
  end

  component :bottom_panel do |c|
    c.klass = BottomPanel
  end

end
