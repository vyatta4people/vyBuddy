class RemoteCommandsGrid < Netzke::Basepack::GridPanel

  #js_mixin :properties
  #js_mixin :init_component

  action :add_in_form,  :text => "Add",  :tooltip => "Add remote command"
  action :edit_in_form, :text => "Edit", :tooltip => "Edit remote command"

  def configuration
    column_defaults                 = Hash.new
    column_defaults[:editable]      = false
    column_defaults[:sortable]      = true
    column_defaults[:menu_disabled] = true
    column_defaults[:resizable]     = false
    column_defaults[:draggable]     = false
    column_defaults[:fixed]         = true

    super.merge(
      :name             => :remote_commands_grid,
      :title            => "Remote commands",
      :model            => "RemoteCommand",
      #:width            => 400,
      :border           => true,
      #:margin           => "0 0 0 0",
      :context_menu     => [:edit_in_form.action, :del.action],
      :tbar             => [:add_in_form.action],
      :bbar             => [],
      :tools            => false,
      :multi_select     => false,
      :columns          => [
        column_defaults.merge(:name => :mode,       :text => "Mode",    :editor => {:xtype => :netzkeremotecombo}),
        column_defaults.merge(:name => :command,    :text => "Command", :flex => true)
      ]
    )
  end

  endpoint :add_form__form_panel0__get_combobox_options do |params|
    case params[:column]
    when "mode"
      { :data => REMOTE_COMMAND_MODES.collect {|m| [m, m]} }
    else
      super
    end
  end

  endpoint :edit_form__form_panel0__get_combobox_options do |params|
    case params[:column]
    when "mode"
      { :data => REMOTE_COMMAND_MODES.collect {|m| [m, m]} }
    else
      super
    end
  end

end
