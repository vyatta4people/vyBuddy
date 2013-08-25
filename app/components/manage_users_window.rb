class ManageUsersWindow < Netzke::Basepack::Window

  def configure(c)
    super
    c.name             = :manage_users_window
    c.title            = "::Users::"
    c.layout           = :border
    c.width            = 500
    c.height           = 500
    c.y                = 50
    c.modal            = true
    c.close_action     = :hide
    c.resizable        = false
    c.items            = [
      {
        netzke_component: :users_grid,
        region:           :center
      }
    ]
  end

  component :users_grid do |c|
    c.klass = UsersGrid
  end

end
