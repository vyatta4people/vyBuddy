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
        Display.create(:vyatta_host_id => vyatta_host.id, :task_remote_command_id => trc.id, :information => "OH SHI-")
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

end
