class LogsWindow < Netzke::Basepack::Window

  js_configure do |c|
    c.mixin :main
  end

  def configure(c)
    super
    c.name             = :logs_window
    c.title            = "::Logs::"
    c.width            = 1000
    c.height           = 600
    c.y                = 100
    c.border           = false
    c.modal            = true
    c.close_action     = :hide
    c.resizable        = false
    c.items            = [
      {
        netzke_component: :logs_grid,
        region:           :center
      }
    ]
  end

  component :logs_grid do |c|
    c.klass = LogsGrid
  end

end
