class TaskRemoteCommandsGrid < Netzke::Basepack::Grid

  js_configure do |c|
    c.mixin :main, :methods
  end

  action :add_in_form do |a|
    a.text      = "Add"
    a.tooltip   = "Add remote command to selected task"
    a.icon      = :brick_add
  end

  action :edit_in_form do |a|
    a.text      = "Edit"
    a.tooltip   = "Edit task's remote command"
    a.icon      = :brick_edit
    a.disabled  = false
  end

  action :del do |a|
    a.icon      = :brick_delete
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
    c.name               = :task_remote_commands_grid
    c.title              = "Remote commands"
    c.prevent_header     = true
    c.model              = "TaskRemoteCommand"
    c.load_inline_data   = false
    c.border             = false
    c.context_menu       = [:edit_in_form, :del]
    c.tbar               = ["<div class='task-details-hint'>Use drag-and-drop to add and sort remote commands</div>"]
    c.bbar               = nil
    c.enable_pagination  = false
    c.tools              = false
    c.multi_select       = false
    c.prohibit_update    = true
    c.view_config        = { :plugins => [ { :ptype => :gridviewdragdrop, :drop_group => :remote_commands_dd_group, }, { :ptype => :gridviewdragdrop, :dd_group => :trc_dd_group, :drag_text => "Drag and drop to reorganize" } ] }
    c.columns            = [
      column_defaults.merge(:name => :task_id,                   :text => "Task",                 :hidden => true,  :editor => {:hidden => true}),
      column_defaults.merge(:name => :mode,    :virtual => true, :text => "Mode",                 :width => 100,    :editor => {:hidden => true}),
      column_defaults.merge(:name => :command, :virtual => true, :text => "Command",              :flex => true,    :editor => {:hidden => true}),
      column_defaults.merge(:name => :command_extension,         :text => "Command extension",    :hidden => true,  :editor => {:field_label => "Command extension", :empty_text => "Extend parent command"}),
      column_defaults.merge(:name => :filter__name,              :text => "Filter",               :width => 100,    :editor => {:field_label => "Filter (to pipe output)", :editable => false, :empty_text => "Choose filter" }),
      column_defaults.merge(:name => :sort_order,                :text => "#",                    :width => 40,     :align => :center, :renderer => "textSteelBlueRenderer", :editor => {:hidden => true})
    ]
  end

  endpoint :reorganize_with_persistent_order do |params, this|
    if params[:position]
      position = params[:position].to_sym
    else
      position = :before
    end
    if params[:local] == true
      # It's a standard drag-and-drop persistent sort
      moved_task_remote_command     = TaskRemoteCommand.find(params[:moved_record_id].to_i)
      replaced_task_remote_command  = TaskRemoteCommand.find(params[:replaced_record_id].to_i)
      return { :set_result => { :success => TaskRemoteCommand.reorganize_with_persistent_order(moved_task_remote_command, replaced_task_remote_command, position, :task_id), :local => true, :message => TaskRemoteCommand.reorganize_with_persistent_order_message } }
    else
      # It's a drag-and-drop from remote commands grid
      moved_task_remote_command = TaskRemoteCommand.create(:task_id => params[:selected_task_id].to_i, :remote_command_id => params[:moved_record_id].to_i, :filter_id => Filter.first.id)
      if moved_task_remote_command.new_record?
        return { :set_result => { :success => false, :local => false, :message => "#{moved_task_remote_command.errors.full_messages.join(', ')}" } }
      end
      if params[:replaced_record_id].to_i == 0
        replaced_task_remote_command = TaskRemoteCommand.where(:task_id => params[:selected_task_id].to_i).last
      else
        replaced_task_remote_command = TaskRemoteCommand.find(params[:replaced_record_id].to_i)
      end
      this.netzke_set_result({ :success => TaskRemoteCommand.reorganize_with_persistent_order(moved_task_remote_command, replaced_task_remote_command, position, :task_id), :local => false, :message => TaskRemoteCommand.reorganize_with_persistent_order_message, :created_record_id => moved_task_remote_command.id })
    end
  end

  endpoint :delete_data do |params, this|
    if !config[:prohibit_delete]
      record_ids = ActiveSupport::JSON.decode(params[:records])
      data_class.destroy(record_ids)
      on_data_changed
      this.netzke_feedback(I18n.t('netzke.basepack.grid_panel.deleted_n_records', :n => record_ids.size), :after_delete => get_data)
    else
      this.netzke_feedback(I18n.t('netzke.basepack.grid_panel.cannot_delete'))
    end
  end

  endpoint :reorder_records do |params, this|
    records           = Array.new
    TaskRemoteCommand.where(:task_id => params[:selected_task_id].to_i).each { |record| records << TaskRemoteCommand.find(record.id) }
    reordered_records = TaskRemoteCommand.reorder_records(records)
    success           = !reordered_records.nil? and !reordered_records.empty? ? true : false
    message           = TaskRemoteCommand.reorder_records_message
    this.netzke_set_result({ :success => success, :message => message })
  end

  def get_combobox_options(params)
    case params[:column]
    when "filter__name"
      return { :data => Filter.all.collect {|f| [f.id, f.name]} }
    end
  end

  endpoint :add_form__netzke_0__get_combobox_options do |params, this|
    this.netzke_set_result(get_combobox_options(params))
  end

  endpoint :edit_form__netzke_0__get_combobox_options do |params, this|
    this.netzke_set_result(get_combobox_options(params))
  end
end