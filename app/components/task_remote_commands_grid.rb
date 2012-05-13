class TaskRemoteCommandsGrid < Netzke::Basepack::GridPanel

  js_mixin :init_component
  js_mixin :methods

  action :add_in_form,  :text => "Add",     :tooltip => "Add remote command to selected task"
  action :edit_in_form, :text => "Edit",    :tooltip => "Edit task's remote command"

  def configuration
    column_defaults                 = Hash.new
    column_defaults[:editable]      = false
    column_defaults[:sortable]      = false
    column_defaults[:menu_disabled] = true
    column_defaults[:resizable]     = false
    column_defaults[:draggable]     = false
    column_defaults[:fixed]         = true

    form_window_config              = Hash.new
    form_window_config[:y]          = 100
    form_window_config[:width]      = 500

    super.merge(
      :name               => :task_remote_commands_grid,
      :title              => "Remote commands for tasks",
      :prevent_header     => true,
      :model              => "TaskRemoteCommand",
      :load_inline_data   => false,
      :border             => false,
      :context_menu       => [:edit_in_form.action, :del.action],
      :tbar               => ["<div class='trc-hint'>Use drag-and-drop to add and sort remote commands</div>"],
      :bbar               => nil,
      :enable_pagination  => false,
      :tools              => false,
      :multi_select       => false,
      :prohibit_update    => true,
      :view_config        => {
        :plugins => [ { :ptype => :gridviewdragdrop, :drag_group => :remote_commands_dd_group, :drop_group => :remote_commands_dd_group, :drag_text => "Drag and drop to reorganize" } ]
      },
      :columns            => [
        column_defaults.merge(:name => :task_id,                   :text => "Task",     :hidden => true,  :editor => {:hidden => true}),
        column_defaults.merge(:name => :mode,    :virtual => true, :text => "Mode",     :width => 100,    :editor => {:hidden => true}),
        column_defaults.merge(:name => :command, :virtual => true, :text => "Command",  :flex => true,    :editor => {:hidden => true}),
        column_defaults.merge(:name => :filter__name,              :text => "Filter",   :width => 100,    :editor => {:editable => false, :empty_text => "Choose filter", :listeners => {:change => {:fn => "function(e){e.expand();e.collapse();}".l} } }),
        column_defaults.merge(:name => :sort_order,                :text => "#",        :width => 40,     :align => :center, :editor => {:hidden => true})
      ],
      :add_form_window_config   => form_window_config,
      :edit_form_window_config  => form_window_config
    )
  end

  endpoint :reorganize_with_persistent_order do |params|
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
      moved_task_remote_command     = TaskRemoteCommand.where(:task_id => params[:selected_task_id].to_i, :remote_command_id => params[:moved_record_id].to_i).first
      if moved_task_remote_command
        return { :set_result => { :success => false, :local => false, :message => "Already added: #{moved_task_remote_command.remote_command.mode}=>#{moved_task_remote_command.remote_command.command}" } }
      else
        moved_task_remote_command = TaskRemoteCommand.create(:task_id => params[:selected_task_id].to_i, :remote_command_id => params[:moved_record_id].to_i, :filter_id => Filter.first.id)
        if params[:replaced_record_id].to_i == 0
          replaced_task_remote_command = TaskRemoteCommand.where(:task_id => params[:selected_task_id].to_i).last
        else
          replaced_task_remote_command = TaskRemoteCommand.find(params[:replaced_record_id].to_i)
        end
        return { :set_result => { :success => TaskRemoteCommand.reorganize_with_persistent_order(moved_task_remote_command, replaced_task_remote_command, position, :task_id), :local => false, :message => TaskRemoteCommand.reorganize_with_persistent_order_message } }
      end
    end
  end

  endpoint :delete_data do |params|
    if !config[:prohibit_delete]
      record_ids = ActiveSupport::JSON.decode(params[:records])
      data_class.destroy(record_ids)
      on_data_changed
      {:netzke_feedback => I18n.t('netzke.basepack.grid_panel.deleted_n_records', :n => record_ids.size), :after_delete => get_data}
    else
      {:netzke_feedback => I18n.t('netzke.basepack.grid_panel.cannot_delete')}
    end
  end

  endpoint :reorder_records do |params|
    records           = Array.new
    TaskRemoteCommand.where(:task_id => params[:selected_task_id].to_i).each { |record| records << TaskRemoteCommand.find(record.id) }
    reordered_records = TaskRemoteCommand.reorder_records(records)
    success           = !reordered_records.nil? and !reordered_records.empty? ? true : false
    message           = TaskRemoteCommand.reorder_records_message
    { :set_result => { :success => success, :message => message } }
  end

  def get_combobox_options(params)
    case params[:column]
    when "filter__name"
      return { :data => Filter.all.collect {|f| [f.id, f.name]} }
 
    end
  end

  endpoint :add_form__netzke_0__get_combobox_options do |params|
    get_combobox_options(params)
  end

  endpoint :edit_form__netzke_0__get_combobox_options do |params|
    get_combobox_options(params)
  end

end