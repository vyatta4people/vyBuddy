class TopPanel < Netzke::Base

  js_configure do |c|
    c.mixin :actions
  end

  action :manage_tasks do |a|
    a.icon = :table_gear
    a.text = ""
  end

  action :manage_users do |a|
    a.icon = :group_gear
    a.text = ""
  end

  action :manage_ssh_key_pairs do |a|
    a.icon = :server_key
    a.text = ""
  end

  action :import_export do |a|
    a.icon    = :import_export
    a.text    = ""
    a.tooltip = "Import/Export"
  end

  action :view_logs do |a|
    a.icon = :newspaper_go
    a.text = ""
  end

  action :manage_settings do |a|
    a.icon = :cog
    a.text = ""
  end

  action :show_about do |a|
    a.icon = :information
    a.text = ""
  end

  action :logout do |a|
    a.icon = :door_out
    a.text = ""
  end

  def configure(c)
    super
    c.name           = :top_panel
    c.title          = "Top (navigation) panel"
    c.prevent_header = true
    c.height         = 38
    c.border         = true
    c.frame          = true
    c.bbar           = navigation_bar
  end

  private

  def navigation_bar
    if session[:user_is_admin]
      return [:manage_tasks, '->', :manage_users, :manage_ssh_key_pairs, "-", :import_export, "-", :view_logs, :manage_settings, '-', :show_about, '-', :logout]
    else
      return ['->', :show_about, '-', :logout]
    end
  end

end
