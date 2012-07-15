class TasksGrid < Netzke::Basepack::GridPanel

  js_mixin :init_component
  js_mixin :methods

  action :add_in_form,  :text => "Add",  :tooltip => "Add task",  :icon => :add
  action :edit_in_form, :text => "Edit", :tooltip => "Edit task", :icon => :pencil, :disabled => false
  action :del, :icon => :delete

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
    form_window_config[:width]      = 700
    form_window_config[:height]     = 420

    super.merge(
      :name             => :tasks_grid,
      :title            => "Tasks",
      :prevent_header   => true,
      :model            => "Task",
      :load_inline_data => false,
      :width            => 350,
      :border           => false,
      :context_menu     => [:edit_in_form.action, :del.action],
      :tbar             => [:add_in_form.action],
      :bbar             => [],
      :rows_per_page    => 18,
      :tools            => false,
      :multi_select     => false,
      :prohibit_update  => true,
      :view_config      => {
        :plugins => [ { :ptype => :gridviewdragdrop, :dd_group => :tasks_dd_group, :drag_text => "Drag and drop to reorganize" } ]
      },
      :columns          => [
        column_defaults.merge(:name => :task_group__name,         :text => "Task group", :hidden => true, :default_value => TaskGroup.first ? TaskGroup.first.id : nil, 
          :editor => {:editable => false, :empty_text => "Choose task group", :listeners => {:change => {:fn => "function(e){e.expand();e.collapse();}".l} } }),
        column_defaults.merge(:name => :task_group__html_name,    :text => "Task group", :renderer => 'boldRenderer', :editor => {:xtype => :textfield, :hidden => true}, :virtual => true),
        column_defaults.merge(:name => :name,                     :text => "Name",                  :hidden => true),
        column_defaults.merge(:name => :html_name,                :text => "Name",                  :flex => true, :editor => {:hidden => true}, :virtual => true),
        column_defaults.merge(:name => :is_on_demand,             :text => "On demand?",            :hidden => true),
        column_defaults.merge(:name => :is_singleton,             :text => "Singleton?",            :hidden => true),
        column_defaults.merge(:name => :group_applicability,      :text => "Group applicability",   :hidden => true, :editor => {:xtype => :netzkeremotecombo, :editable => false}),
        column_defaults.merge(:name => :match_hostname,           :text => "Match hostname",        :hidden => true, :editor => {:disabled => true}),
        column_defaults.merge(:name => :sort_order,               :text => "#",                     :width => 40, :align => :center, :renderer => "textSteelBlueRenderer", :editor => {:hidden => true}),
        column_defaults.merge(:name => :is_enabled,               :text => "Enabled?",              :hidden => true),
        column_defaults.merge(:name => :comment,                  :text => "Comment",               :hidden => true, :editor => {:height => 150})
      ],
      :add_form_window_config   => form_window_config,
      :edit_form_window_config  => form_window_config
    )
  end

  endpoint :reorganize_with_persistent_order do |params|
    moved_task    = Task.find(params[:moved_record_id].to_i)
    replaced_task = Task.find(params[:replaced_record_id].to_i)
    position      = params[:position].to_sym
    success       = Task.reorganize_with_persistent_order(moved_task, replaced_task, position, :task_group_id)
    return { :set_result => { :success => success, :message => Task.reorganize_with_persistent_order_message } }
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
    Task.where(:task_group_id => params[:selected_task_group_id].to_i).each { |record| records << Task.find(record.id) }
    reordered_records = Task.reorder_records(records)
    success           = !reordered_records.nil? and !reordered_records.empty? ? true : false
    message           = Task.reorder_records_message
    { :set_result => { :success => success, :message => message } }
  end

  def get_combobox_options(params)
    case params[:column]
    when "task_group__name"
      return { :data => TaskGroup.enabled.collect {|t| [t.id, t.name]} }
    when "group_applicability"
      return { :data => GROUP_APPLICABILITIES.collect {|g| [g, g]} }
    end
  end

  endpoint :add_form__netzke_0__get_combobox_options do |params|
    get_combobox_options(params)
  end

  endpoint :edit_form__netzke_0__get_combobox_options do |params|
    get_combobox_options(params)
  end

end