class LoginWindow < Netzke::Basepack::Window

  #js_mixin :actions

  action :login, :icon => :tick, :text => "Login"

  def configuration
    super.merge(
      :name             => :login_window,
      :title            => "::Login::",
      :width            => 400,
      :y                => 100,
      :border           => false,
      :modal            => true,
      :closable         => false,
      :resizable        => false,
      :draggable        => false,
      :hidden           => false,
      :items            => [ {
        :xtype            => :form,
        :prevent_header   => true,
        :border           => false,
        :frame            => true,
        :buttons          => [ { :action => :login, :form_bind => true } ],
        :default_type     => :textfield,
        :defaults         => { :anchor => "100%", :label_pad => 0, :allow_blank => false },
        :items            => [ {
          :name         => :username,
          :field_label  => "Username"
        }, {
          :name         => :password,
          :field_label  => "Password"          
        } ]
      } ]
    )
  end

end