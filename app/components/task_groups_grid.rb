class TaskGroupsGrid < Netzke::Basepack::GridPanel

  js_mixin :init_component

  action :add_in_form,  :text => "Add",  :tooltip => "Add task group"
  action :edit_in_form, :text => "Edit", :tooltip => "Edit task group"

  def configuration
    column_defaults                 = Hash.new
    column_defaults[:editable]      = false
    column_defaults[:sortable]      = false
    column_defaults[:menu_disabled] = true
    column_defaults[:resizable]     = false
    column_defaults[:draggable]     = false
    column_defaults[:fixed]         = true

    super.merge(
      :name             => :task_groups_grid,
      :title            => "Task groups",
      :model            => "TaskGroup",
      :load_inline_data => false,
      :scope            => lambda { |s| s.sorted },
      :border           => false,
      :context_menu     => [:edit_in_form.action, :del.action],
      :tbar             => [:add_in_form.action],
      :bbar             => [],
      :tools            => false,
      :multi_select     => false,
      :view_config      => {
        :plugins => [ { :ptype => :gridviewdragdrop, :drag_group => :task_groups_grid_dd_group, :drop_group => :task_groups_grid_dd_group, :drag_text => "Drag and drop to reorganize" } ]
      },
      :columns          => [
        column_defaults.merge(:name => :name,                     :text => "Name",            :flex => true),
        column_defaults.merge(:name => :sort_order,               :text => "Order",           :editor => {:min_value => 0}),
        column_defaults.merge(:name => :is_enabled,               :text => "Enabled?",        :hidden => true)
      ]
    )
  end

  endpoint :reorganize_with_persistent_order do |params|
    moved_task_group    = TaskGroup.find(params[:moved_record_id].to_i)
    replaced_task_group = TaskGroup.find(params[:replaced_record_id].to_i)
    success             = TaskGroup.reorganize_with_persistent_order(moved_task_group, replaced_task_group)
    return { :set_result => { :success => success, :message => TaskGroup.reorganize_with_persistent_order_message } }
  end

end
