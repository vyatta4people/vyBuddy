class TopPanel < Netzke::Basepack::Panel
  action :manage_tasks,         :icon => :table_gear,                 :text => ""
  action :manage_users,         :icon => :group_gear,                 :text => ""
  action :manage_ssh_key_pairs, :icon => :server_key,                 :text => ""
  action :import_export,        :icon => :import_export,              :text => "", :tooltip => "Import/Export"
  action :view_logs,            :icon => :newspaper_go,               :text => ""
  action :manage_settings,      :icon => :cog,                        :text => ""
  action :show_about,           :icon => :information,                :text => ""
  action :logout,               :icon => :door_out,                   :text => ""

  js_mixin :actions

  def get_bbar
    if session[:user_is_admin]
      return [:manage_tasks.action, '->', :manage_users.action, :manage_ssh_key_pairs.action, "-", :import_export.action, "-", :view_logs.action, :manage_settings.action, '-', :show_about.action, '-', :logout.action]
    else
      return ['->', :show_about.action, '-', :logout.action]
    end
  end

  def configure(c)
    super
      :name           => :top_panel,
      :title          => "Top",
      :prevent_header => true,
      :height         => 38,
      :border         => true,
      :frame          => true, 
      :bbar           => get_bbar
    )
  end

end
