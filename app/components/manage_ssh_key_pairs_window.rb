class ManageSshKeyPairsWindow < Netzke::Basepack::Window

  def configuration
    super.merge(
      :name             => :manage_ssh_key_pairs_window,
      :title            => "::SSH public/private key pairs::",
      :layout           => :border,
      :width            => 400,
      :height           => 500,
      :y                => 50,
      :modal            => true,
      :close_action     => :hide,
      :resizable        => false,
      :items            => [
        :ssh_key_pairs_grid.component(
          :name       => :ssh_key_pairs_grid,
          :region     => :center,
          :class_name => "SshKeyPairsGrid"
        )
      ]
    )
  end

end