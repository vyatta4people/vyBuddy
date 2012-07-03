class TaskVyattaHostGroupsGrid < Netzke::Basepack::GridPanel

  js_mixin :init_component
  js_mixin :methods

  def configuration
    column_defaults                 = Hash.new
    column_defaults[:editable]      = false
    column_defaults[:sortable]      = false
    column_defaults[:menu_disabled] = true
    column_defaults[:resizable]     = false
    column_defaults[:draggable]     = false
    column_defaults[:fixed]         = true

    super.merge(
      :name               => :task_vyatta_host_groups_grid,
      :title              => "Host groups",
      :prevent_header     => true,
      :model              => "TaskVyattaHostGroup",
      :load_inline_data   => false,
      :border             => false,
      :context_menu       => [:del.action],
      :tbar               => ["<div class='task-details-hint'>Use drag-and-drop to add Vyatta host groups</div>"],
      :bbar               => ["Totals: TODO"],
      :enable_pagination  => false,
      :tools              => false,
      :multi_select       => false,
      :prohibit_update    => true,
      :view_config        => {
        :plugins => [ { :ptype => :gridviewdragdrop, :dd_group => :vyatta_host_groups_dd_group, :drag_text => "You can't escape from the heroine!" } ]
      },
      :columns            => [
        column_defaults.merge(:name => :task_id,                   :text => "Task",        :hidden => true),
        column_defaults.merge(:name => :vyatta_host_group__name,   :text => "Name",        :flex => true, :getter => lambda { |tvhg| tvhg.vyatta_host_group.html_name }, :renderer => 'boldRenderer'),
        column_defaults.merge(:name => :list_of_members,           :text => "Members",     :width => 150, :getter => lambda { |tvhg| tvhg.vyatta_host_group.html_list_of_members }, :virtual => true),
        column_defaults.merge(:name => :number_of_members,         :text => "Qty",         :width => 50,  :getter => lambda { |tvhg| tvhg.vyatta_host_group.number_of_members }, :align => :center, :virtual => true)
      ]
    )
  end

  endpoint :add_task_vyatta_host_group do |params|
    success                 = false
    conditions              = { :task_id => params[:task_id].to_i, :vyatta_host_group_id => params[:vyatta_host_group_id].to_i }
    task_vyatta_host_group  = TaskVyattaHostGroup.find(:first, :conditions => conditions)
    if task_vyatta_host_group
      message = "Already exists"
    else
      task_vyatta_host_group = TaskVyattaHostGroup.create(conditions)
      if task_vyatta_host_group
        success = true
      else
        message = "Failed to create"
      end
    end
    return { :set_result => { :success => success, :message => message } }
  end

  endpoint :delete_data do |params|
    record_ids = ActiveSupport::JSON.decode(params[:records])
    data_class.destroy(record_ids)
    {:netzke_feedback => I18n.t('netzke.basepack.grid_panel.deleted_n_records', :n => record_ids.size), :after_delete => get_data}
  end

end