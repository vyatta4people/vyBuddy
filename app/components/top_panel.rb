class TopPanel < Netzke::Basepack::Panel
  action :manage_users,         :icon => :group_gear,                 :text => ""
  action :manage_ssh_key_pairs, :icon => :server_key,                 :text => ""
  action :manage_tasks,         :icon => :table_gear,                 :text => ""
  action :show_help,            :icon => :help,                       :text => ""
  action :logout,               :icon => :door_out,                   :text => ""

  js_mixin :actions

  def configuration
    super.merge(
      :name           => :top_panel,
      :title          => "Top",
      :prevent_header => true,
      :height         => 38,
      :border         => true,
      :margin         => 5,
      :frame          => true,
      :bbar           => [:manage_users.action, :manage_ssh_key_pairs.action, "-", :manage_tasks.action, '->', :show_help.action, '-', :logout.action]
    )
  end

end
