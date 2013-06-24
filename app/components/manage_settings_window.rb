class ManageSettingsWindow < Netzke::Basepack::Window

  def configure(c)
    super
    c.name             = :manage_settings_window
    c.title            = "::Settings::"
    c.layout           = :border
    c.width            = 400
    c.height           = 500
    c.y                = 50
    c.modal            = true
    c.close_action     = :hide
    c.resizable        = false
    c.items            = [
      {
        :name       => :settings_grid,
        :region     => :center,
        :class_name => "SettingsGrid"
      }
    ]
  end

end
