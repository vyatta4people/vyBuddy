class ManageSshKeyPairsWindow < Netzke::Basepack::Window

  def configure(c)
    super
    c.name             = :manage_ssh_key_pairs_window
    c.title            = "::SSH public/private key pairs::"
    c.layout           = :border
    c.width            = 400
    c.height           = 500
    c.y                = 50
    c.modal            = true
    c.close_action     = :hide
    c.resizable        = false
    c.items            = [
      {
        netzke_component: :ssh_key_pairs_grid,
        region:           :center
      }
    ]
  end

  component :ssh_key_pairs_grid do |c|
    c.klass = SshKeyPairsGrid
  end

end
