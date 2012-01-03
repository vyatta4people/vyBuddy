class DisplayTasksTabPanel < Netzke::Basepack::TabPanel

  js_mixin :init_component

  def items
    task_groups       = TaskGroup.where(:is_enabled => true)
    task_group_items  = Array.new
    task_groups.each do |task_group|
      task_group_item                     = Hash.new
      task_group_item[:id]                = task_group.html_id
      task_group_item[:name]              = task_group_item[:id]
      task_group_item[:title]             = task_group.name
      task_group_item[:class_name]        = "Netzke::Basepack::TabPanel"
      task_group_item[:xtype]             = :tabpanel # This is required to make nested TabPanel work ;)
      task_group_item[:deferred_render]   = false
      task_group_item[:items]             = Array.new
      task_group.tasks.where(:is_enabled => true).each do |task|
        task_item               = Hash.new
        task_item[:id]          = task.html_id
        task_item[:name]        = task_item[:id]
        task_item[:title]       = task.name
        task_item[:class_name]  = "Netzke::Basepack::Panel"
        task_item[:auto_scroll] = true
        task_item[:html]        = task.task_remote_commands.collect{ |trc| "<pre class='display-information'><div id='#{trc.html_display_id}' class='display'></div></pre>" }.join
        task_group_item[:items] << task_item
      end
      task_group_items << task_group_item
    end
    return task_group_items
  end

  def configuration
    super.merge(
      :name             => :display_tasks_tab_panel,
      :title            => "Tasks to display",
      :border           => true,
      :frame            => false,
      :deferred_render  => false
    )
  end

end
