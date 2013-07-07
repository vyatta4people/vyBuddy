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
    c.layout         = :border
    c.body_style     = {"background-color" => "#e4ebef"}
    c.items          = [
     # {
     #   :netzke_component       => :top_panel,
     #   :region     => :north,
     #   :class_name => "TopPanel",
     #   :margin     => "5 5 5 5"
     # }, {
     #   :name       => :vyatta_hosts_grid,
     #   :region     => :west,
     #   :class_name => "VyattaHostsGrid",
     #   :margin     => "0 0 0 5",
     #   :split      => true
     # },
     {
        netzke_component: :bottom_panel,
        region: :center#,
        #js_config: ""
        #class_name: "DisplayTasksTabPanel1",
        #margin: "0 5 0 0"
      }
    #, {
    #    :name       => :bottom_panel,
    #    :region     => :south,
    #    :class_name => "BottomPanel",
    #    :margin     => "4 4 4 4"
    #  }
    ]
  end

  component :bottom_panel do |c|
    c.klass = BottomPanel
    c.desc = "DisplayTasksTabPanel"
  end

end
