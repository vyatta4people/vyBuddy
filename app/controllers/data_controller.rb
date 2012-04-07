class DataController < ApplicationController

  before_filter :user_authenticated?

  def get_global_summary
    global_summary = Hash.new
    global_summary[:total_vyatta_hosts]        = VyattaHost.count
    global_summary[:enabled_vyatta_hosts]      = VyattaHost.where(:is_enabled => true).count
    global_summary[:unreachable_vyatta_hosts]  = VyattaHost.where(:is_enabled => true, 'vyatta_host_states.is_reachable' => false).count
    render(:json => global_summary)
  end

  def get_displays_for_vyatta_host
    vyatta_host = VyattaHost.find(params[:id].to_i)
    data        = Array.new
    TaskRemoteCommand.find(:all).each do |trc|
      if !Display.find(:first, :conditions => { :vyatta_host_id => vyatta_host.id, :task_remote_command_id => trc.id })
        Display.create(:vyatta_host_id => vyatta_host.id, :task_remote_command_id => trc.id, :information => "Coming soon...")
      end
    end
    vyatta_host.displays.each do |display|
      item = Hash.new
      item[:html_display_id] = display.html_display_id
      item[:information]     = display.information
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
