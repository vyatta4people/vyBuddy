class ManageUsersWindow < Netzke::Basepack::Window

  def configuration
    super.merge(
      :name             => :manage_users_window,
      :title            => "::Users::",
      :layout           => :border,
      :width            => 500,
      :height           => 500,
      :y                => 50,
      :modal            => true,
      :close_action     => :hide,
      :resizable        => false,
      :items            => [
        :users_grid.component(
          :name       => :users_grid,
          :region     => :center,
          :class_name => "UsersGrid"
        )
      ]
    )
  end

end