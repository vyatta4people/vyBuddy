class DisplayTasksTabPanel < Netzke::Basepack::TabPanel

  js_mixin :init_component

  def get_display_containers(task)
    if !task.writer?
      return task.task_remote_commands.collect{ |trc| "<div id='#{trc.html_display_id}' class='display-container'></div>" }.join
    else
      return "<div class='display-united-top-container'>" + task.task_remote_commands.collect{ |trc| "<div id='#{trc.html_display_id}' class='display-united-container'></div>" }.join + "</div>" +
        "<div class='display-container'><pre><div id='#{task.html_united_information_id}' class='display-information'></div></pre></div>"
    end
  end

  def items
    task_groups       = TaskGroup.enabled
    task_group_items  = Array.new
    task_groups.each do |task_group|
      task_group_item                     = Hash.new
      task_group_item[:id]                = task_group.html_id
      task_group_item[:name]              = task_group_item[:id]
      task_group_item[:title]             = task_group.name
      task_group_item[:title]             += " <span style=\"background-color:##{task_group.color};\">&nbsp;&nbsp;&nbsp;&nbsp;</span>" if task_group.fill_tab_with_color
      task_group_item[:class_name]        = "Netzke::Basepack::TabPanel"
      task_group_item[:xtype]             = :tabpanel # This is required to make nested TabPanel work ;)
      task_group_item[:deferred_render]   = false

      task_group_item[:items]             = Array.new
      task_group.tasks.enabled.each do |task|
        task_item                       = Hash.new
        task_item[:id]                  = task.html_id
        task_item[:name]                = task_item[:id]
        task_item[:title]               = task.title
        task_item[:class_name]          = "Netzke::Basepack::Panel"
        task_item[:auto_scroll]         = true
        task_item[:html]                = "<div id='#{task.html_dummy_id}' class='task-dummy'>&nbsp;</div>"        
        task_item[:html]                += "<div id='#{task.html_not_applicable_id}' class='task-not-applicable'>Not applicable to this host...</div>"        
        task_item[:html]                += "<div id='#{task.html_container_id}' class='task-container'>"
        button_template                 = DirectoryTemplate::ErbTemplate.new(File.read(ActionController::Base.view_paths[0].to_s + '/data/task_button_container.html.erb'))
        task_item[:html]                += button_template.result(:html_button_container_id => task.html_button_container_id)
        comment_template                = DirectoryTemplate::ErbTemplate.new(File.read(ActionController::Base.view_paths[0].to_s + '/data/task_comment_container.html.erb'))
        task_item[:html]                += comment_template.result(:html_comment_container_id => task.html_comment_container_id)
        task_item[:html]                += get_display_containers(task)
        task_item[:html]                += "<div>&nbsp;</div>"
        task_item[:html]                += "</div>"
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

  endpoint :execute_task do |params|
    vyatta_host = VyattaHost.find(params[:vyatta_host_id].to_i)
    task        = Task.find(params[:task_id].to_i)
    if vyatta_host.execute_task(task)
      success = true
      message = "Task \"#{task.name}\" executed successfully."
    else
      success = false
      message = "Failed to execute task \"#{task.name}\"! Please examine logs."
    end
    return { :set_result => { :success => success, :message => message, :verbose => false } }
  end 

  endpoint :get_task_comment do |params|
    comment = Rinku.auto_link(Task.find(params[:task_id].to_i).comment)
    comment = '<i style="color:#777777;">No comment</i>' if comment.empty?
    return { :set_result => { :comment => comment } }
  end

end