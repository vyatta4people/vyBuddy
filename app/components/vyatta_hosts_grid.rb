class VyattaHostsGrid < Netzke::Basepack::GridPanel

  js_mixin :init_component
  js_mixin :actions
  js_mixin :methods

  action :add_in_form,    :text => "Add",  :tooltip => "Add Vyatta host",  :icon => :server_add 
  action :edit_in_form,   :text => "Edit", :tooltip => "Edit Vyatta host", :icon => :server_edit, :disabled => false
  action :del, :icon => :server_delete, :disabled => false

  action :execute_all_tasks,          :text => "Execute all tasks",         :tooltip => "Execute all tasks",        :icon => :arrow_refresh
  action :execute_on_demand_tasks,    :text => "Execute on-demand tasks",   :tooltip => "Execute on-demand tasks",  :icon => :arrow_refresh
  action :execute_background_tasks,   :text => "Execute background tasks",  :tooltip => "Execute background tasks", :icon => :arrow_refresh

  def configuration
    column_defaults                 = Hash.new
    column_defaults[:editable]      = false
    column_defaults[:sortable]      = false
    column_defaults[:menu_disabled] = true
    column_defaults[:resizable]     = false
    column_defaults[:draggable]     = false
    column_defaults[:fixed]         = true
    column_defaults[:editor]        = {:allow_blank => false}

    form_window_config              = Hash.new
    form_window_config[:y]          = 100
    form_window_config[:width]      = 500

    super.merge(
      :name               => :vyatta_hosts_grid,
      :title              => "Vyatta hosts",
      :model              => "VyattaHost",
      :load_inline_data   => false,
      :width              => 600,
      :border             => true,
      :context_menu       => session[:user_is_admin] ? [:execute_all_tasks.action, :execute_on_demand_tasks.action, :execute_background_tasks.action, '-', :edit_in_form.action, :del.action] : [:execute_all_tasks.action, :execute_on_demand_tasks.action, :execute_background_tasks.action],
      :tbar               => session[:user_is_admin] ? [:add_in_form.action] : [],
      :bbar               => [],
      :enable_pagination  => false,
      :tools              => false,
      :multi_select       => false,
      :prohibit_update    => true,
      :view_config        => { :load_mask => false },
      :columns            => [
        column_defaults.merge(:name => :user__username,           :text => "Owner",                 :hidden => true, 
          :editor => {:editable => false, :empty_text => "Choose user",     :listeners => {:change => {:fn => "function(e){e.expand();e.collapse();}".l} } }), 
        column_defaults.merge(:name => :ssh_key_pair__identifier, :text => "SSH key pair",          :hidden => true, 
          :editor => {:editable => false, :empty_text => "Choose key pair", :listeners => {:change => {:fn => "function(e){e.expand();e.collapse();}".l} } } ),
        column_defaults.merge(:name => :hostname,                 :text => "Hostname",              :flex => true),
        column_defaults.merge(:name => :remote_address,           :text => "Remote address",        :hidden => true),
        column_defaults.merge(:name => :remote_port,              :text => "Remote port",           :hidden => true, :default_value => 22, :editor => {:allow_decimals => false, :auto_strip_chars => true, :min_value => 1,  :max_value => 65535}),
        column_defaults.merge(:name => :polling_interval,         :text => "Polling interval",      :hidden => true, :default_value => 60, :editor => {:allow_decimals => false, :auto_strip_chars => true, :min_value => 30, :max_value => 86400}),
        column_defaults.merge(:name => :is_passive,               :text => "Passive?",              :hidden => true),
        column_defaults.merge(:name => :is_monitored,             :text => "Monitored?",            :hidden => true),
        column_defaults.merge(:name => :is_enabled,               :text => "Enabled?",              :hidden => true),
        column_defaults.merge(:name => :is_daemon_running,        :text => "Daemon running?",       :width => 110, :attr_type => :boolean, :align => :center, :renderer => 'booleanRenderer'),
        column_defaults.merge(:name => :is_reachable,             :text => "Reachable? (real)",     :width => 110, :attr_type => :boolean, :hidden => true),
        column_defaults.merge(:name => :reachability,             :text => "Reachable?",            :width => 100, :attr_type => :integer, :align => :center, :renderer => 'booleanRenderer2', :virtual => true),
        column_defaults.merge(:name => :vyatta_version,           :text => "Version",               :width => 150),
        column_defaults.merge(:name => :load_average,             :text => "Load average",          :width => 90, :format => '0.00', :xtype => :numbercolumn)
      ],
      :add_form_window_config   => form_window_config,
      :edit_form_window_config  => form_window_config
    )
  end

  endpoint :get_user_rights do |params|
    case params[:action]
    when "edit_in_form"
      return { :set_result => session[:user_is_admin] }
    end
    return { :set_result => false }
  end

  def get_combobox_options(params)
    case params[:column]
    when "user__username"
      return { :data => User.enabled.collect {|u| [u.id, u.username]} }
    when "ssh_key_pair__identifier"
      return { :data => SshKeyPair.all.collect {|s| [s.id, s.identifier]} }
    end
  end

  endpoint :add_form__netzke_0__get_combobox_options do |params|
    get_combobox_options(params)
  end

  endpoint :edit_form__netzke_0__get_combobox_options do |params|
    get_combobox_options(params)
  end

  endpoint :execute_tasks do |params|
    success     = false
    message     = ""
    vyatta_host = VyattaHost.find(params[:vyatta_host_id].to_i)
    task_type   = params[:task_type].to_sym
    task_count  = vyatta_host.execute_tasks(task_type)
    if task_count
      success = true
      message = "Executed #{task_count.to_s} tasks for #{vyatta_host.label}"
    else
      message = "Unable to execute tasks for #{vyatta_host.label}"
    end
    return { :set_result => { :success => success, :message => message } }
  end

end