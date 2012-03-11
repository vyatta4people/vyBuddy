class RemoteCommandsGrid < Netzke::Basepack::GridPanel

  action :add_in_form,  :text => "Add",  :tooltip => "Add remote command"
  action :edit_in_form, :text => "Edit", :tooltip => "Edit remote command"

  def configuration
    column_defaults                 = Hash.new
    column_defaults[:editable]      = false
    column_defaults[:sortable]      = false
    column_defaults[:menu_disabled] = true
    column_defaults[:resizable]     = false
    column_defaults[:draggable]     = false
    column_defaults[:fixed]         = true

    super.merge(
      :name             => :remote_commands_grid,
      :title            => "Remote commands",
      :model            => "RemoteCommand",
      :scope            => lambda { |s| s.sorted },
      :border           => false,
      :context_menu     => [:edit_in_form.action, :del.action],
      :tbar             => [:add_in_form.action],
      :bbar             => [],
      :tools            => false,
      :multi_select     => false,
      :view_config        => {
        :plugins => [ { :ptype => :gridviewdragdrop, :drag_group => :remote_commands_dd_group, :drag_text => "Drag remote command to task area" } ]
      },
      :columns          => [
        column_defaults.merge(:name => :mode,       :text => "Mode",    :editor => {:xtype => :netzkeremotecombo}),
        column_defaults.merge(:name => :command,    :text => "Command", :flex => true)
      ]
    )
  end

  def get_combobox_options(params)
    case params[:column]
    when "mode"
      return { :data => REMOTE_COMMAND_MODES.collect {|m| [m, m]} }
    end
    super
  end

  endpoint :add_form__netzke_0__get_combobox_options do |params|
    get_combobox_options(params)
  end

  endpoint :edit_form__netzke_0__get_combobox_options do |params|
    get_combobox_options(params)
  end

end
