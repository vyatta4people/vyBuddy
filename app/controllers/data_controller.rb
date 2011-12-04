class DataController < ApplicationController
  
  def get_global_summary
    global_summary = Hash.new
    global_summary[:total_vyatta_hosts]        = VyattaHost.count
    global_summary[:enabled_vyatta_hosts]      = VyattaHost.where(:is_enabled => true).count
    global_summary[:unreachable_vyatta_hosts]  = VyattaHost.where(:is_enabled => true, 'vyatta_host_states.is_reachable' => false).count
    render(:json => global_summary)
  end

  def get_displays_for_vyatta_host
    vyatta_host = VyattaHost.find(params[:vyatta_host_id].to_i)
    data        = Array.new
    vyatta_host.displays.each do |display|
      item = Hash.new
      item[:html_display_id] = display.html_display_id
      item[:information]     = display.information
      data << item
    end
    render(:json => data)
  end

end
