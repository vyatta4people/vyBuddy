class TasksGrid < Netzke::Basepack::GridPanel

  js_mixin :properties
  js_mixin :init_component

  action :add_in_form,  :text => "Add",  :tooltip => "Add Vyatta host"
  action :edit_in_form, :text => "Edit", :tooltip => "Edit Vyatta host"

  def configuration
    column_defaults                 = Hash.new
    column_defaults[:editable]      = false
    column_defaults[:sortable]      = true
    column_defaults[:menu_disabled] = true
    column_defaults[:resizable]     = false
    column_defaults[:draggable]     = false
    column_defaults[:fixed]         = true

    super.merge(
      :name             => :tasks_grid,
      :title            => "Tasks",
      :prevent_header   => true,
      :model            => "Task",
      :width            => 400,
      :border           => true,
      :margin           => "0 0 0 0",
      :split            => false,
      :context_menu     => [:edit_in_form.action, :del.action],
      :tbar             => [:add_in_form.action],
      :bbar             => [],
      :tools            => false,
      :multi_select     => false,
      :columns          => [
        column_defaults.merge(:name => :task_group__name,         :text => "Task group",      :hidden => true, :default_value => TaskGroup.first ? TaskGroup.first.id : nil),
        column_defaults.merge(:name => :name,                     :text => "Name",            :flex => true),
        column_defaults.merge(:name => :is_enabled,               :text => "Enabled?",        :hidden => true)
      ]
    )
  end

end
