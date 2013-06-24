class LoginWindow < Netzke::Basepack::Window

  js_configure do |c|
    c.mixin :main, :actions
  end

  action :login do |a|
    a.icon = :tick
    a.text = "Login"
  end

  def configure(c)
    super
    c.name             = :login_window
    c.title            = "::Login::"
    c.width            = 400
    c.y                = 100
    c.border           = false
    c.modal            = true
    c.closable         = false
    c.resizable        = false
    c.draggable        = false
    c.hidden           = false
    c.items            = [ {
      :id               => :login_form,
      :xtype            => :form,
      :prevent_header   => true,
      :border           => false,
      :frame            => true,
      :buttons          => [ :login ],
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
        :name         => :log_application,
        :value        => super[:log_application],
        :hidden       => true
      }, {
        :name         => :log_event_source,
        :value        => super[:log_event_source],
        :hidden       => true
      } ]
    } ]
  end

  endpoint :login do |params, this|
    success   = false
    user      = User.find_by_username(params[:username])
    if user
      if user.password == params[:password]
        if user.is_enabled
          session[:user_id]         = user.id
          session[:user_username]   = user.username
          success                   = true
        end
      end
    end

    Log.application   = params[:log_application]
    Log.event_source  = params[:log_event_source]
    if success
      Log.info("User logged in: #{session[:user_username]}(#{session[:user_id]})")
    else
      Log.warn("User failed to log in: #{params[:username]}")
    end
    this.netzke_set_result(success)
  end

end
