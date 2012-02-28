class VyattaHostsGrid < Netzke::Basepack::GridPanel

  js_mixin :init_component

  action :add_in_form,  :text => "Add",  :tooltip => "Add Vyatta host"
  action :edit_in_form, :text => "Edit", :tooltip => "Edit Vyatta host"

  def configuration
    column_defaults                 = Hash.new
    column_defaults[:editable]      = false
    column_defaults[:sortable]      = false
    column_defaults[:menu_disabled] = true
    column_defaults[:resizable]     = false
    column_defaults[:draggable]     = false
    column_defaults[:fixed]         = true

    super.merge(
      :name             => :vyatta_hosts_grid,
      :title            => "Vyatta hosts",
      :model            => "VyattaHost",
      :load_inline_data => false,
      :scope            => lambda { |s| s.sorted },
      :width            => 600,
      :border           => true,
      :context_menu     => session[:user_is_admin] ? [:edit_in_form.action, :del.action] : false,
      :tbar             => session[:user_is_admin] ? [:add_in_form.action] : [],
      :bbar             => [],
      :tools            => false,
      :multi_select     => false,
      :view_config      => { :load_mask => false },
      :columns          => [
        column_defaults.merge(:name => :user__username,           :text => "Owner",           :hidden => true, :default_value => User.first ? User.first.id : nil),
        column_defaults.merge(:name => :ssh_key_pair__identifier, :text => "SSH key",         :hidden => true, :default_value => SshKeyPair.first ? SshKeyPair.first.id : nil),
        column_defaults.merge(:name => :hostname,                 :text => "Hostname",        :flex => true),
        column_defaults.merge(:name => :remote_address,           :text => "Remote Address",  :hidden => true),
        column_defaults.merge(:name => :is_enabled,               :text => "Enabled?",        :hidden => true),
        column_defaults.merge(:name => :is_daemon_running,        :text => "Daemon running?", :width => 110, :attr_type => :boolean, :align => :center, :renderer => 'booleanRenderer'),
        column_defaults.merge(:name => :is_reachable,             :text => "Reachable?",      :width => 100, :attr_type => :boolean, :align => :center, :renderer => 'booleanRenderer'),
        column_defaults.merge(:name => :vyatta_version,           :text => "Version",         :width => 150),
        column_defaults.merge(:name => :load_average,             :text => "Load Average",    :width => 90, :format => '0.00', :xtype => :numbercolumn)
      ]
    )
  end

  endpoint :get_user_rights do |params|
    case params[:action]
    when "edit_in_form"
      return { :set_result => session[:user_is_admin] }
    end
    return { :set_result => false }
  end

end
