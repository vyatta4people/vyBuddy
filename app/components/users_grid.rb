class UsersGrid < Netzke::Basepack::GridPanel

  js_mixin :init_component

  action :add_in_form,  :text => "Add",  :tooltip => "Add user",  :icon => :user_add
  action :edit_in_form, :text => "Edit", :tooltip => "Edit user", :icon => :user_edit, :disabled => false
  action :del, :icon => :user_delete

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
      :name             => :users_grid,
      :title            => "Users",
      :prevent_header   => true,
      :model            => "User",
      :border           => true,
      :context_menu     => [:edit_in_form.action, :del.action],
      :tbar             => [:add_in_form.action],
      :bbar             => [],
      :tools            => false,
      :multi_select     => false,
      :prohibit_update  => true,
      :columns          => [
        column_defaults.merge(:name => :username,           :text => "Username",  :width => 120),
        column_defaults.merge(:name => :email,              :text => "Email",     :flex => true),
        column_defaults.merge(:name => :password,           :text => "Password",  :hidden => true,  :editor => {:input_type => :password}),
        column_defaults.merge(:name => :is_enabled,         :text => "Enabled?",  :width => 80,     :align => :center),
        column_defaults.merge(:name => :is_admin,           :text => "Admin?",    :width => 80,     :align => :center)
      ],
      :add_form_window_config   => form_window_config,
      :edit_form_window_config  => form_window_config
    )
  end

end
