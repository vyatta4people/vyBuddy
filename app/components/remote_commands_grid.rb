class RemoteCommandsGrid < Netzke::Basepack::Grid

  js_configure do |c|
    c.mixin :main
  end

  action :add_in_form do |a|
    a.text      = "Add"
    a.tooltip   = "Add remote command"
    a.icon      = :brick_add
  end

  action :edit_in_form do |a|
    a.text      = "Edit"
    a.tooltip   = "Edit remote command"
    a.icon      = :brick_edit
    a.disabled  = false
  end

  action :del do |a|
    a.icon      = :brick_delete
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
    c.name             = :remote_commands_grid
    c.title            = "Remote commands"
    c.model            = "RemoteCommand"
    c.border           = false
    c.context_menu     = [:edit_in_form, :del]
    c.tbar             = [:add_in_form]
    c.bbar             = []
    c.rows_per_page    = 15
    c.tools            = false
    c.multi_select     = false
    c.prohibit_update  = true
    c.view_config      = { :plugins => [ { :ptype => :gridviewdragdrop, :drag_group => :remote_commands_dd_group, :drag_text => "Drag and drop remote command to task details area" } ] }
    c.columns          = [
      column_defaults.merge(:name => :mode,       :text => "Mode",    :editor => {:xtype => :netzkeremotecombo, :editable => false}),
      column_defaults.merge(:name => :command,    :text => "Command", :flex => true)
    ]
  end

  def get_combobox_options(params)
    case params[:column]
    when "mode"
      return { :data => REMOTE_COMMAND_MODES.collect {|m| [m, m]} }
    end
    super
  end

  endpoint :add_form__netzke_0__get_combobox_options do |params, this|
    this.netzke_set_result(get_combobox_options(params))
  end

  endpoint :edit_form__netzke_0__get_combobox_options do |params, this|
    this.netzke_set_result(get_combobox_options(params))
  end

end
