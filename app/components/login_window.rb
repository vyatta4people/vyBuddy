class LoginWindow < Netzke::Basepack::Window

  js_mixin :init_component
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
        }, {
          :name         => :remote_ip,
          :field_label  => "Remote IP",
          :value        => super[:remote_ip],
          :hidden       => true
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
          session[:user_id]         = user.id
          session[:user_username]   = user.username
          success                   = true
        end
      end
    end

    Log.application   = :auth_controller
    Log.event_source  = params[:remote_ip]
    if success
      Log.info("User logged in: #{session[:user_username]}(#{session[:user_id]})")
    else
      Log.warn("User failed to log in: #{params[:username]}")
    end

    { :set_result => success }
  end

end