class RemoteCommandsGrid < Netzke::Basepack::GridPanel

  js_mixin :init_component

  action :add_in_form,  :text => "Add",  :tooltip => "Add remote command",  :icon => :brick_add
  action :edit_in_form, :text => "Edit", :tooltip => "Edit remote command", :icon => :brick_edit, :disabled => false
  action :del, :icon => :brick_delete

  def configuration
    column_defaults                 = Hash.new
    column_defaults[:editable]      = false
    column_defaults[:sortable]      = false
    column_defaults[:menu_disabled] = true
    column_defaults[:resizable]     = false
    column_defaults[:draggable]     = false
    column_defaults[:fixed]         = true

    form_window_config              = Hash.new
    form_window_config[:y]          = 100
    form_window_config[:width]      = 500

    super.merge(
      :name             => :remote_commands_grid,
      :title            => "Commands",
      :model            => "RemoteCommand",
      :border           => false,
      :context_menu     => [:edit_in_form.action, :del.action],
      :tbar             => [:add_in_form.action],
      :bbar             => [],
      :rows_per_page    => 15,
      :tools            => false,
      :multi_select     => false,
      :prohibit_update  => true,
      :view_config      => {
        :plugins => [ { :ptype => :gridviewdragdrop, :drag_group => :remote_commands_dd_group, :drag_text => "Drag remote command to task area" } ]
      },
      :columns          => [
        column_defaults.merge(:name => :mode,       :text => "Mode",    :editor => {:xtype => :netzkeremotecombo, :editable => false}),
        column_defaults.merge(:name => :command,    :text => "Command", :flex => true)
      ],
      :add_form_window_config   => form_window_config,
      :edit_form_window_config  => form_window_config
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
