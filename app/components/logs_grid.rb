class LogsGrid < Netzke::Basepack::Grid

  js_configure do |c|
    c.mixin :main, :actions
  end

  action :search_logs do |a|
    a.icon = :find
    a.text = ""
  end

  action :clear_search_filter do |a|
    a.icon = :stop
    a.text = ""
  end

  action :download_logs do |a|
    a.icon      = :download
    a.text      = ""
    a.disabled  = true
  end

  def configure(c)
    column_defaults                 = Hash.new
    column_defaults[:editable]      = false
    column_defaults[:sortable]      = false
    column_defaults[:menu_disabled] = true
    column_defaults[:resizable]     = false
    column_defaults[:draggable]     = false
    column_defaults[:fixed]         = true

    super
    c.name               = :logs_grid
    c.title              = "Logs"
    c.prevent_header     = true
    c.model              = "Log"
    c.scope              = lambda { |r| r.where(get_scope_where_clause) }
    c.load_inline_data   = false
    c.border             = true
    c.context_menu       = false
    c.tbar               = [
      " ", { :xtype => :displayfield, :field_label => "From", :label_width => :auto },
      { :item_id => :from_date,      :xtype => :datefield,     :value => Date.today, :format => "Y-m-d", :width => 100 },
      "  ", { :xtype => :displayfield, :field_label => "To", :label_width => :auto },
      { :item_id => :to_date,        :xtype => :datefield,     :value => Date.today, :format => "Y-m-d", :width => 100 },
      "  ", { :xtype => :displayfield, :field_label => "#{Log.html_severity(:INFO)} #{Log.html_severity(:WARN)} #{Log.html_severity(:ERROR)} #{Log.html_severity(:FATAL)}", :label_width => :auto, :label_separator => "" },
      { :item_id => :silent_log,     :xtype => :checkboxfield },
      "->", { :xtype => :displayfield, :field_label => "Search", :label_width => :auto },
      { :item_id => :search_message, :xtype => :textfield,     :width => 300, :empty_text => "Search log message..." },
      " ", :search_logs, :clear_search_filter, :download_logs, " "
    ]
    c.bbar               = [ ]
    c.tools              = false
    c.multi_select       = true
    c.rows_per_page      = 20
    c.prohibit_update    = true
    c.columns            = [
      { :xtype => :rownumberer, :text => "#", :width => 40, :align => :center },
      column_defaults.merge(:name => :created_at,         :hidden => true),
      column_defaults.merge(:name => :logged_at,          :text => "Logged at",     :width => 150, :xtype => :datecolumn, :format => "Y-m-d H:i:s T"),
      column_defaults.merge(:name => :application,        :text => "Application",   :width => 100, :renderer => "textSteelBlueBoldRenderer"),
      column_defaults.merge(:name => :event_source,       :text => "Event source",  :width => 120, :renderer => "textSteelBlueRenderer"),
      column_defaults.merge(:name => :severity,           :text => "Severity",      :width => 75,  :align => :center, :getter => lambda {|r| r.html_severity }),
      column_defaults.merge(:name => :message,            :text => "Message",       :flex => true, :getter => lambda {|r| r.html_message })
    ]
  end

  def get_scope_where_clause
    conditions = Array.new
    conditions << "created_date >= \"#{component_session[:from_date]}\""      if component_session[:from_date]
    conditions << "created_date <= \"#{component_session[:to_date]}\""        if component_session[:to_date]
    conditions << "NOT is_verbose"                                            if component_session[:silent_log]
    conditions << "message LIKE \"%#{component_session[:search_message]}%\""  if component_session[:search_message] and !component_session[:search_message].empty?

    return conditions.join(" AND ")
  end

  endpoint :search_logs do |params, this|
    component_session[:from_date]         = params[:from_date].to_date
    component_session[:to_date]           = params[:to_date].to_date
    component_session[:silent_log]        = params[:silent_log]
    component_session[:search_message]    = params[:search_message]
  end

end
