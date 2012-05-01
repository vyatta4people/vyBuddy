class LogsGrid < Netzke::Basepack::GridPanel
  action :search_logs,          :icon => :find,       :text => ""
  action :clear_search_filter,  :icon => :stop,       :text => ""
  action :download_logs,        :icon => :download,   :text => "", :disabled => true

  js_mixin :init_component
  js_mixin :actions

  def configuration
    column_defaults                 = Hash.new
    column_defaults[:editable]      = false
    column_defaults[:sortable]      = true
    column_defaults[:menu_disabled] = true
    column_defaults[:resizable]     = false
    column_defaults[:draggable]     = false
    column_defaults[:fixed]         = true

    super.merge(
      :name               => :logs_grid,
      :title              => "Logs",
      :prevent_header     => true,
      :model              => "Log",
      :load_inline_data   => false,
      :border             => true,
      :context_menu       => false,
      :tbar               => [
          " ", { :xtype => :displayfield, :field_label => "From", :label_width => :auto },
          { :item_id => :from_date,      :xtype => :datefield,     :value => Date.today, :format => "Y-m-d", :width => 100 },
          "  ", { :xtype => :displayfield, :field_label => "To", :label_width => :auto },
          { :item_id => :to_date,        :xtype => :datefield,     :value => Date.today, :format => "Y-m-d", :width => 100 }, 
          "  ", { :xtype => :displayfield, :field_label => "#{Log.html_severity(:INFO)} #{Log.html_severity(:WARN)} #{Log.html_severity(:ERROR)} #{Log.html_severity(:FATAL)}", :label_width => :auto, :label_separator => "" },
          { :item_id => :silent_log,     :xtype => :checkboxfield },
          "->", { :xtype => :displayfield, :field_label => "Search", :label_width => :auto },
          { :item_id => :search_message, :xtype => :textfield,     :width => 300, :empty_text => "Search log message..." },
          " ",
          :search_logs.action, :clear_search_filter.action, :download_logs.action,
          " "
        ],
      :bbar               => [],
      :tools              => false,
      :multi_select       => true,
      :load_inline_data   => false,
      :rows_per_page      => 20,
      :columns            => [
        { :xtype => :rownumberer, :text => "#", :width => 40, :align => :center },
        column_defaults.merge(:name => :created_at,         :text => "Logged at",     :width => 150, :format => "Y-m-d H:i:s T"),
        column_defaults.merge(:name => :application,        :text => "Application",   :width => 100, :renderer => "textSteelBlueBoldRenderer"),
        column_defaults.merge(:name => :event_source,       :text => "Event source",  :width => 120, :renderer => "textSteelBlueRenderer"),
        column_defaults.merge(:name => :severity,           :text => "Severity",      :width => 75,  :align => :center, :getter => lambda {|r| r.html_severity }),
        column_defaults.merge(:name => :message,            :text => "Message",       :flex => true, :getter => lambda {|r| r.html_message })
      ]  
    )
  end

end
