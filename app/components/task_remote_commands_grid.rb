class TaskRemoteCommandsGrid < Netzke::Basepack::GridPanel

  js_mixin :properties
  js_mixin :init_component

  action :add_in_form,  :text => "Add",  :tooltip => "Add remote command to selected task"
  action :edit_in_form, :text => "Edit", :tooltip => "Edit task's remote command"

  def configuration
    column_defaults                 = Hash.new
    column_defaults[:editable]      = false
    column_defaults[:sortable]      = true
    column_defaults[:menu_disabled] = true
    column_defaults[:resizable]     = false
    column_defaults[:draggable]     = false
    column_defaults[:fixed]         = true

    super.merge(
      :name               => :tasks_grid,
      :title              => "Remote commands for task",
      :model              => "TaskRemoteCommand",
      :border             => true,
      :margin             => "0 0 0 0",
      :split              => false,
      :context_menu       => [:edit_in_form.action, :del.action],
      :tbar               => [:add_in_form.action],
      :bbar               => [],
      :enable_pagination  => false,
      :tools              => false,
      :multi_select       => false,
      :columns            => [
        column_defaults.merge(:name => :task__name,                :text => "Task",     :hidden => true),
        column_defaults.merge(:name => :remote_command__mode,      :text => "Mode",     :width => 100),
        column_defaults.merge(:name => :remote_command__command,   :text => "Command",  :flex => true),
        column_defaults.merge(:name => :filter__name,              :text => "Filter",   :width => 100)
      ]
    )
  end

end
