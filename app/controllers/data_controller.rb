class DataController < ApplicationController

  before_filter :user_authenticated?

  def get_global_summary
    global_summary = Hash.new
    global_summary[:total_vyatta_hosts]        = VyattaHost.count
    global_summary[:enabled_vyatta_hosts]      = VyattaHost.enabled.count
    global_summary[:unreachable_vyatta_hosts]  = VyattaHost.enabled.joins(:vyatta_host_state).where('vyatta_host_states.is_reachable' => false).count
    render(:json => global_summary)
  end

  def get_displays_for_vyatta_host
    vyatta_host = VyattaHost.find(params[:id].to_i)
    data        = Array.new
    TaskRemoteCommand.find(:all).each do |trc|
      if !Display.find(:first, :conditions => { :vyatta_host_id => vyatta_host.id, :task_remote_command_id => trc.id })
        Display.create(:vyatta_host_id => vyatta_host.id, :task_remote_command_id => trc.id, :information => "Not yet baby...")
      end
    end
    vyatta_host.displays.each do |display|
      item = Hash.new
      item[:html_display_id]                  = display.html_display_id
      item[:information]                      = display.information
      item[:remote_command_mode]              = display.task_remote_command.mode
      item[:remote_command]                   = display.task_remote_command.command
      item[:filter]                           = display.task_remote_command.filter.name
      item[:show_as_one]                      = display.task_remote_command.task.writer?
      item[:html_united_information_id]       = display.task_remote_command.task.html_united_information_id
      item[:updated_at]                       = display.updated_at.localtime.strftime("%Y-%m-%d %H:%M:%S %Z")
      data << item
    end
    render(:json => data)
  end

  def get_tasks
    data = Array.new
    Task.all.each do |task|
      item = Hash.new
      item[:id]                         = task.id
      item[:contains_variables]         = task.contains_variables?
      item[:variables]                  = task.variables
      item[:html_group_id]              = task.task_group.html_id
      item[:html_id]                    = task.html_id
      item[:html_dummy_id]              = task.html_dummy_id
      item[:html_not_applicable_id]     = task.html_not_applicable_id
      item[:html_container_id]          = task.html_container_id
      item[:html_button_container_id]   = task.html_button_container_id
      item[:html_execute_button_id]     = task.html_execute_button_id
      item[:html_comment_button_id]     = task.html_comment_button_id
      item[:html_comment_container_id]  = task.html_comment_container_id
      item[:is_comment_empty]           = task.comment.empty?
      data << item
    end
    render(:json => data)
  end

  def export_logs
    conditions    = Array.new
    conditions[0] = "`created_date` >= ? AND `created_date` <= ?"
    conditions[1] = params[:from_date].to_date
    conditions[2] = params[:to_date].to_date
    if params[:silent_log] == "true"
      conditions[0] += " AND NOT `is_verbose`"
    end
    if params[:search_message] and !params[:search_message].empty?
      conditions[0] += " AND `message` LIKE ?"
      conditions[3] = "%#{params[:search_message]}%"
    end
    logs   = Log.find(:all, :conditions => conditions)
    data   = Array.new
    logs.each do |log|
      data << log.as_text
    end
    send_data(data.join("\n"), :filename => "logs_#{Time.now.strftime("%Y%m%d%H%M%S")}.txt")
  end

end
