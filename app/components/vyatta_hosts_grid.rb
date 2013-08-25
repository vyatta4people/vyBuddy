class VyattaHostsGrid < Netzke::Basepack::Grid

  js_configure do |c|
    c.mixin :main, :actions, :methods
  end

  action :add_in_form do |a|
    a.text    = "Add"
    a.tooltip = "Add Vyatta host"
    a.icon    = :server_add
  end

  action :edit_in_form do |a|
    a.text    = "Edit"
    a.tooltip = "Edit Vyatta host"
    a.icon    = :server_edit
  end

  action :del do |a|
    a.text    = "Delete"
    a.tooltip = "Delete Vyatta host"
    a.icon    = :server_delete
  end

  action :bulk_add do |a|
    a.text    = "Bulk add"
    a.tooltip = "Bulk add Vyatta hosts"
    a.icon    = :server_bulk_add
  end

  action :execute_all_tasks do |a|
    a.text        = "Execute all tasks"
    a.tooltip     = "Execute all tasks"
    a.icon        = :arrow_refresh
  end

  action :execute_on_demand_tasks  do |a|
    a.text        = "Execute on-demand tasks"
    a.tooltip     = "Execute on-demand tasks"
    a.icon        = :arrow_refresh
  end

  action :execute_background_tasks do |a|
    a.text        = "Execute background tasks"
    a.tooltip     = "Execute background tasks"
    a.icon        = :arrow_refresh
  end

  def configure(c)
    column_defaults                 = Hash.new
    column_defaults[:editable]      = false
    column_defaults[:sortable]      = false
    column_defaults[:menu_disabled] = true
    column_defaults[:resizable]     = false
    column_defaults[:draggable]     = false
    column_defaults[:fixed]         = true
    column_defaults[:editor]        = {:allow_blank => false}

    super
    c.name               = :vyatta_hosts_grid
    c.title              = "Vyatta hosts"
    c.model              = "VyattaHost"
    c.load_inline_data   = false
    c.width              = 550
    c.border             = true
    c.context_menu       = session[:user_is_admin] ? [:execute_all_tasks, :execute_on_demand_tasks, :execute_background_tasks, '-', :edit_in_form] : [:execute_all_tasks, :execute_on_demand_tasks, :execute_background_tasks]
    #c.tbar               = session[:user_is_admin] ? [:add_in_form, :bulk_add] : []
    c.tbar               = session[:user_is_admin] ? [:add_in_form] : []
    c.bbar               = session[:user_is_admin] ? ["<div class='vyatta-host-hint'>Use drag-and-drop to arrange Vyatta hosts</div>", '->', :del] : []
    c.enable_pagination  = false
    c.tools              = false
    c.multi_select       = false
    #c.prohibit_update    = true
    c.view_config        = { :load_mask => false, :plugins => [ { :ptype => :gridviewdragdrop, :dd_group => :vyatta_hosts_dd_group, :drag_text => "Drag and drop to reorganize" } ] }
      c.columns            = [
        column_defaults.merge(:name => :vyatta_host_group__name,        :text => "Host group",      :hidden => true,
                              :editor => {:editable => false, :empty_text => "Choose group" }),
        column_defaults.merge(:name => :vyatta_host_group__html_name,   :text => "Host group",      :width => 110, :renderer => 'boldRenderer', :editor => {:xtype => :textfield, :hidden => true}, :virtual => true),
        column_defaults.merge(:name => :ssh_key_pair__identifier, :text => "SSH key pair",          :hidden => true,
                              :editor => {:editable => false, :empty_text => "Choose key pair" } ),
        column_defaults.merge(:name => :hostname,                 :text => "Hostname",              :hidden => true),
        column_defaults.merge(:name => :html_hostname,            :text => "Hostname",              :flex => true, :editor => {:hidden => true}, :virtual => true),
        column_defaults.merge(:name => :remote_address,           :text => "Remote address",        :hidden => true),
        column_defaults.merge(:name => :remote_port,              :text => "Remote port",           :hidden => true, :default_value => 22, :editor => {:allow_decimals => false, :auto_strip_chars => true, :min_value => 1,  :max_value => 65535}),
        column_defaults.merge(:name => :polling_interval,         :text => "Polling interval",      :hidden => true, :default_value => 60, :editor => {:allow_decimals => false, :auto_strip_chars => true, :min_value => 30, :max_value => 86400}),
        column_defaults.merge(:name => :is_passive,               :text => "Passive?",              :hidden => true),
        column_defaults.merge(:name => :is_monitored,             :text => "Monitored?",            :hidden => true),
        column_defaults.merge(:name => :is_enabled,               :text => "Enabled?",              :hidden => true),
        column_defaults.merge(:name => :is_daemon_running,        :text => "Daemon running?",       :hidden => true, :attr_type => :boolean, :virtual => true),
        column_defaults.merge(:name => :is_reachable,             :text => "Reachable? (real)",     :attr_type => :boolean, :hidden => true, :virtual => true),
        column_defaults.merge(:name => :reachability,             :text => "Reachable?",            :width => 80, :attr_type => :integer, :align => :center, :renderer => 'booleanRenderer2', :virtual => true),
        column_defaults.merge(:name => :vyatta_version,           :text => "Version",               :width => 110, :align => :center, :virtual => true),
        column_defaults.merge(:name => :load_average,             :text => "Load avg",              :width => 70,  :format => '0.00', :xtype => :numbercolumn, :align => :center, :virtual => true),
        column_defaults.merge(:name => :sort_order,               :text => "#",                     :width => 40,  :align => :center, :renderer => "textSteelBlueRenderer", :editor => {:hidden => true})
      ]
  end

  component :add_window do |c|
    super(c)
    c.form_config.items = [:hostname, :remote_address, :remote_port, :polling_interval, :is_passive, :is_monitored, :is_enabled]
  end

  component :edit_window do |c|
    super(c)
    c.form_config.items = [:hostname, :remote_address, :remote_port, :polling_interval, :is_passive, :is_monitored, :is_enabled]
  end

  endpoint :reorganize_with_persistent_order do |params, this|
    moved_vyatta_host     = VyattaHost.find(params[:moved_record_id].to_i)
    replaced_vyatta_host  = VyattaHost.find(params[:replaced_record_id].to_i)
    position              = params[:position].to_sym
    success               = VyattaHost.reorganize_with_persistent_order(moved_vyatta_host, replaced_vyatta_host, position, :vyatta_host_group_id)
    this.netzke_set_result({ :success => success, :message => Task.reorganize_with_persistent_order_message })
  end

  endpoint :delete_data do |params, this|
    if !config[:prohibit_delete]
      record_ids = ActiveSupport::JSON.decode(params[:records])
      data_class.destroy(record_ids)
      on_data_changed
      {:netzke_feedback => I18n.t('netzke.basepack.grid_panel.deleted_n_records', :n => record_ids.size), :after_delete => get_data}
    else
      {:netzke_feedback => I18n.t('netzke.basepack.grid_panel.cannot_delete')}
    end
  end

  endpoint :reorder_records do |params, this|
    records           = Array.new
    VyattaHost.where(:vyatta_host_group_id => params[:selected_vyatta_host_group_id].to_i).each { |record| records << VyattaHost.find(record.id) }
    reordered_records = VyattaHost.reorder_records(records)
    success           = !reordered_records.nil? and !reordered_records.empty? ? true : false
    message           = VyattaHost.reorder_records_message
    this.netzke_set_result({ :success => success, :message => message })
  end

  endpoint :get_user_rights do |params, this|
    case params[:action]
      when "edit_in_form"
        this.netzke_set_result(session[:user_is_admin])
      when "execute_task"
        this.netzke_set_result(session[:user_is_admin])
    end
    this.netzke_set_result(false)
  end

  def get_combobox_options(params)
    case params[:column]
      when "vyatta_host_group__name"
        return { :data => VyattaHostGroup.all.collect {|g| [g.id, g.name]} }
      when "ssh_key_pair__identifier"
        return { :data => SshKeyPair.all.collect {|s| [s.id, s.identifier]} }
    end
  end

  endpoint :add_form__netzke_0__get_combobox_options do |params, this|
    get_combobox_options(params)
  end

  endpoint :edit_form__netzke_0__get_combobox_options do |params, this|
    get_combobox_options(params)
  end

  endpoint :execute_tasks do |params, this|
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
    this.netzke_set_result({ :success => success, :message => message })
  end

  endpoint :get_applicable_tasks do |params, this|
    vyatta_host         = VyattaHost.find(params[:vyatta_host_id].to_i)
    applicable_task_ids = Array.new
    Task.enabled.each do |task|
      applicable_task_ids[task.id] = true if task.applicable?(vyatta_host)
    end
    this.netzke_set_result({ :applicable_task_ids => applicable_task_ids })
  end

end
