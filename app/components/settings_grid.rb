class SettingsGrid < Netzke::Basepack::GridPanel

  def configure(c)
    column_defaults                 = Hash.new
    column_defaults[:editable]      = false
    column_defaults[:sortable]      = false
    column_defaults[:menu_disabled] = true
    column_defaults[:resizable]     = false
    column_defaults[:draggable]     = false
    column_defaults[:fixed]         = true

    super
      :name               => :settings_grid,
      :title              => "Settings",
      :prevent_header     => true,
      :model              => "Setting",
      :border             => false,
      :context_menu       => [],
      :tbar               => false,
      :bbar               => ['HINT: Double-click on value cell to start editing.', '->', :apply.action],
      :enable_pagination  => false,
      :tools              => false,
      :multi_select       => false,
      :columns            => [
        column_defaults.merge(:name => :name,       :text => "Name",  :width => 150, :renderer => "boldRenderer"),
        column_defaults.merge(:name => :value,      :text => "Value", :flex => true, :editable => true, :getter => lambda { |v| v.grid_value } )
      ]
    )
  end

end
