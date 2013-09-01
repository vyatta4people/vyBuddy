class TasksGrid < Netzke::Basepack::Grid

  js_configure do |c|
    c.mixin :main, :methods
  end

  action :add_in_form do |a|
    a.text      = "Add"
    a.tooltip   = "Add task"
    a.icon      = :add
  end

  action :edit_in_form do |a|
    a.text      = "Edit"
    a.tooltip   = "Edit task"
    a.icon      = :pencil
    a.disabled  = false
  end

  action :del do |a|
    a.icon      = :delete
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
    c.name             = :tasks_grid
    c.title            = "Tasks"
    c.prevent_header   = true
    c.model            = "Task"
    c.load_inline_data = false
    c.width            = 300
    c.border           = false
    c.context_menu     = [:edit_in_form, :del]
    c.tbar             = [:add_in_form]
    c.bbar             = []
    c.rows_per_page    = 18
    c.tools            = false
    c.multi_select     = false
    c.prohibit_update  = true
    c.view_config      = { :plugins => [ { :ptype => :gridviewdragdrop, :dd_group => :tasks_dd_group, :drag_text => "Drag and drop to reorganize" } ] }
     c.columns         = [
        column_defaults.merge(:name => :task_group__name,         :text => "Task group", :hidden => true, :default_value => TaskGroup.first ? TaskGroup.first.id : nil, 
          :editor => {:editable => false, :empty_text => "Choose task group" }),
        column_defaults.merge(:name => :task_group__html_name,    :text => "Task group", :renderer => 'boldRenderer', :editor => {:xtype => :textfield, :hidden => true}, :virtual => true),
        column_defaults.merge(:name => :name,                     :text => "Name",                  :hidden => true),
        column_defaults.merge(:name => :html_name,                :text => "Name",                  :flex => true, :editor => {:hidden => true}, :virtual => true),
        column_defaults.merge(:name => :is_on_demand,             :text => "On demand?",            :hidden => true),
        column_defaults.merge(:name => :is_singleton,             :text => "Singleton?",            :hidden => true),
        column_defaults.merge(:name => :is_writer,                :text => "Writer?",               :hidden => true),
        column_defaults.merge(:name => :group_applicability,      :text => "Group applicability",   :hidden => true, :editor => {:xtype => :netzkeremotecombo, :editable => false}),
        column_defaults.merge(:name => :match_hostname,           :text => "Match hostname",        :hidden => true, :editor => {:disabled => true}),
        column_defaults.merge(:name => :sort_order,               :text => "#",                     :width => 40, :align => :center, :renderer => "textSteelBlueRenderer", :editor => {:hidden => true}),
        column_defaults.merge(:name => :is_enabled,               :text => "Enabled?",              :hidden => true),
        column_defaults.merge(:name => :comment,                  :text => "Comment",               :hidden => true, :editor => {:height => 150})
      ]
  end

  endpoint :reorganize_with_persistent_order do |params, this|
    moved_task    = Task.find(params[:moved_record_id].to_i)
    replaced_task = Task.find(params[:replaced_record_id].to_i)
    position      = params[:position].to_sym
    success       = Task.reorganize_with_persistent_order(moved_task, replaced_task, position, :task_group_id)
    this.netzke_set_result({ :success => success, :message => Task.reorganize_with_persistent_order_message })
  end

  endpoint :delete_data do |params, this|
    if !config[:prohibit_delete]
      record_ids = ActiveSupport::JSON.decode(params[:records])
      data_class.destroy(record_ids)
      on_data_changed
      this.netzke_feedback(I18n.t('netzke.basepack.grid_panel.deleted_n_records', :n => record_ids.size))
    else
      this.netzke_feedback(I18n.t('netzke.basepack.grid_panel.cannot_delete'))
    end
  end

  endpoint :reorder_records do |params, this|
    records           = Array.new 
    Task.where(:task_group_id => params[:selected_task_group_id].to_i).each { |record| records << Task.find(record.id) }
    reordered_records = Task.reorder_records(records)
    success           = !reordered_records.nil? and !reordered_records.empty? ? true : false
    message           = Task.reorder_records_message
    this.netzke_set_result({ :success => success, :message => message })
  end

  def get_combobox_options(params)
    case params[:column]
    when "task_group__name"
      return { :data => TaskGroup.enabled.collect {|t| [t.id, t.name]} }
    when "group_applicability"
      return { :data => GROUP_APPLICABILITIES.collect {|g| [g, g]} }
    end
  end

  endpoint :add_form__netzke_0__get_combobox_options do |params, this|
    this.netzke_set_result(get_combobox_options(params))
  end

  endpoint :edit_form__netzke_0__get_combobox_options do |params, this|
    this.netzke_set_result(get_combobox_options(params))
  end

end