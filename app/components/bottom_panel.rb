class BottomPanel < Netzke::Basepack::Panel

  js_configure do |c|
    c.mixin :main
  end

  def configure(c)
    super
    c.name           = :bottom_panel
    c.title          = "Bottom"
    c.prevent_header = true
    c.height         = 40
    c.border         = true
    c.frame          = false
    c.html           = ERB.new(File.read(ActionController::Base.view_paths[0].to_s + '/data/global_summary.html.erb')).result
  end

end
