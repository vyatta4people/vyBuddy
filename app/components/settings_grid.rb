class SettingsGrid < Netzke::Basepack::Grid

  def configure(c)
    column_defaults                 = Hash.new
    column_defaults[:editable]      = false
    column_defaults[:sortable]      = false
    column_defaults[:menu_disabled] = true
    column_defaults[:resizable]     = false
    column_defaults[:draggable]     = false
    column_defaults[:fixed]         = true

    super
    c.name               = :settings_grid,
    c.title              = "Settings",
    c.prevent_header     = true,
    c.model              = "Setting",
    c.border             = false,
    c.context_menu       = [],
    c.tbar               = false,
    c.bbar               = ['HINT: Double-click on value cell to start editing.', '->', :apply],
    c.enable_pagination  = false,
    c.tools              = false,
    c.multi_select       = false,
    c.columns            = [
      column_defaults.merge(:name => :name,       :text => "Name",  :width => 150, :renderer => "boldRenderer"),
      column_defaults.merge(:name => :value,      :text => "Value", :flex => true, :editable => true, :getter => lambda { |v| v.grid_value } )
      ]
  end

end
