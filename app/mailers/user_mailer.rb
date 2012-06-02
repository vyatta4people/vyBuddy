class UserMailer < ActionMailer::Base

  def self.smtp_settings
    smtp_settings = { :address => Setting.get(:smtp_host), :port => Setting.get(:smtp_port), :enable_starttls_auto => Setting.get(:smtp_use_ssl) }
    smtp_settings = smtp_settings.merge(:user_name => Setting.get(:smtp_username), :password => Setting.get(:smtp_password), :authentication => Setting.get(:smtp_auth_type)) if Setting.get(:smtp_use_auth)
    return smtp_settings
  end

  def self.raise_delivery_errors
    return true
  end
  
  def vyatta_host_state_change_notification(user, vyatta_host)
    @user               = user
    @vyatta_host        = vyatta_host
    @time               = Time.now.localtime
    @system_name        = Setting.get(:system_name)
    @system_email       = Setting.get(:smtp_from)
    @system_url         = Setting.get(:system_url)
    mail(:from => @system_email, :to => @user.email, :subject => "[#{@system_name}] Host state changed: #{@vyatta_host.hostname} become #{@vyatta_host.public_reachability}")
  end

end
