class LoginWindow < Netzke::Basepack::Window

  js_mixin :actions

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
        :id               => :login_form,
        :xtype            => :form,
        :prevent_header   => true,
        :border           => false,
        :frame            => true,
        :buttons          => [ :login.action ],
        :default_type     => :textfield,
        :defaults         => { :anchor => "100%", :label_pad => 0, :allow_blank => false },
        :items            => [ {
          :name         => :username,
          :field_label  => "Username"
        }, {
          :name         => :password,
          :field_label  => "Password",
          :input_type   => :password
        } ]
      } ]
    )
  end

  endpoint :login do |params|
    success = false
    user = User.find_by_username(params[:username])
    if user
      if user.password == params[:password]
        if user.is_enabled
          session[:user_id] = user.id
          success           = true
        end
      end
    end
    { :set_result => success }
  end

end