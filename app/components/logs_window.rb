class LogsWindow < Netzke::Basepack::Window

  js_mixin :init_component

  def configuration
    super.merge(
      :name             => :logs_window,
      :title            => "::Logs::",
      :width            => 1000,
      :height           => 600,
      :y                => 100,
      :border           => false,
      :modal            => true,
      :close_action     => :hide,
      :resizable        => false,
      :items            => [ { :name => :logs_grid, :class_name => "LogsGrid" } ]
    )
  end

end
