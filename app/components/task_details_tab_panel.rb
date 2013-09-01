class TaskDetailsTabPanel < Netzke::Base

  js_configure do |c|
    c.extend = "Ext.tab.Panel"
  end

  def configure(c)
    super
    c.name           = :task_details_tab_panel
    c.title          = "Task details"
    c.prevent_header = true
    c.border         = true
    c.margin         = "2 0 2 0"
    c.active_tab     = 0
  end

end
