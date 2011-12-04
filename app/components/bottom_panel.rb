class BottomPanel < Netzke::Basepack::Panel

  js_mixin :properties
  js_mixin :init_component

  def configuration
    super.merge(
      :name           => :bottom_panel,
      :title          => "Bottom",
      :prevent_header => true,
      :height         => 40,
      :border         => true,
      :margin         => 5,
      :frame          => false,
      :html           => ERB.new(File.read(ActionController::Base.view_paths[0].to_s + '/data/global_summary.html.erb')).result
    )
  end

end
