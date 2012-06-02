class ManageSettingsWindow < Netzke::Basepack::Window

  def configuration
    super.merge(
      :name             => :manage_settings_window,
      :title            => "::Settings::",
      :layout           => :border,
      :width            => 400,
      :height           => 500,
      :y                => 50,
      :modal            => true,
      :close_action     => :hide,
      :resizable        => false,
      :items            => [
        :settings_grid.component(
          :name       => :settings_grid,
          :region     => :center,
          :class_name => "SettingsGrid"
        )
      ]
    )
  end

end
