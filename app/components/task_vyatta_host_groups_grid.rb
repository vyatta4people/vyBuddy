class TaskVyattaHostGroupsGrid < Netzke::Basepack::Grid

  js_configure do |c|
    c.mixin :main, :methods
  end

  def configure(c)
    column_defaults                 = Hash.new
    column_defaults[:editable]      = false
    column_defaults[:sortable]      = false
    column_defaults[:menu_disabled] = true
    column_defaults[:resizable]     = false
    column_defaults[:draggable]     = false
    column_defaults[:fixed]         = true

    super
    c.name = :task_vyatta_host_groups_grid
    c.title = "Host groups"
    c.prevent_header = true
    c.model = "TaskVyattaHostGroup"
    c.load_inline_data = false
    c.border = false
    c.context_menu = [:del]
    c.tbar = ["<div class='task-details-hint'>Use drag-and-drop to add Vyatta host groups</div>"]
    c.bbar = false
    c.enable_pagination = false
    c.tools = false
    c.multi_select = false
    c.prohibit_update = true
    c.view_config = {
        :plugins => [ { :ptype => :gridviewdragdrop, :drop_group => :vyatta_host_groups_dd_group, :drag_text => "Wazzup dude? Relax!" } ]
      }
    c.columns = [
        column_defaults.merge(:name => :task_id,                   :text => "Task",        :hidden => true),
        column_defaults.merge(:name => :vyatta_host_group__name,   :text => "Name",        :flex => true, :getter => lambda { |tvhg| tvhg.vyatta_host_group.html_name }, :renderer => 'boldRenderer'),
        column_defaults.merge(:name => :list_of_members,           :text => "Members",     :width => 150, :getter => lambda { |tvhg| tvhg.vyatta_host_group.html_list_of_members }, :virtual => true),
        column_defaults.merge(:name => :number_of_members,         :text => "Qty",         :width => 50,  :getter => lambda { |tvhg| tvhg.vyatta_host_group.number_of_members }, :align => :center, :virtual => true),
        column_defaults.merge(:name => :includability,             :text => "Inc?",        :width => 50,  :align => :center, :virtual => true, :renderer => 'booleanRenderer2')
      ]
  end

  endpoint :add_task_vyatta_host_group do |params, this|
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
    this.netzke_set_result({ :success => success, :message => message })
    this.after_delete(get_data)
  end

  endpoint :delete_data do |params, this|
    record_ids = ActiveSupport::JSON.decode(params[:records])
    data_class.destroy(record_ids)
    this.netzke_feedback(I18n.t('netzke.basepack.grid_panel.deleted_n_records', :n => record_ids.size))
  end

end