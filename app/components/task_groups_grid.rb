class TaskGroupsGrid < Netzke::Basepack::GridPanel

  #js_mixin :properties
  #js_mixin :init_component

  action :add_in_form,  :text => "Add",  :tooltip => "Add task group"
  action :edit_in_form, :text => "Edit", :tooltip => "Edit task group"

  def configuration
    column_defaults                 = Hash.new
    column_defaults[:editable]      = false
    column_defaults[:sortable]      = true
    column_defaults[:menu_disabled] = true
    column_defaults[:resizable]     = false
    column_defaults[:draggable]     = false
    column_defaults[:fixed]         = true

    super.merge(
      :name             => :task_groups_grid,
      :title            => "Task groups",
      :model            => "TaskGroup",
      #:width            => 300,
      :border           => true,
      #:margin           => "0 0 0 0",
      :context_menu     => [:edit_in_form.action, :del.action],
      :tbar             => [:add_in_form.action],
      :bbar             => [],
      :tools            => false,
      :multi_select     => false,
      :columns          => [
        column_defaults.merge(:name => :name,                     :text => "Name",            :flex => true),
        column_defaults.merge(:name => :is_enabled,               :text => "Enabled?",        :hidden => true)
      ]
    )
  end

end