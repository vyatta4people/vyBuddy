class UsersGrid < Netzke::Basepack::Grid

  js_configure do |c|
    c.mixin :main
  end

  action :add_in_form do |a|
    a.text      = "Add"
    a.tooltip   = "Add user"
    a.icon      = :user_add
  end

  action :edit_in_form do |a|
    a.text      = "Edit"
    a.tooltip   = "Edit user"
    a.icon      = :user_edit
    a.disabled  = false
  end

  action :del do |a|
    a.icon      = :user_delete
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
    c.name             = :users_grid
    c.title            = "Users"
    c.prevent_header   = true
    c.model            = "User"
    c.border           = true
    c.context_menu     = [:edit_in_form, :del]
    c.tbar             = [:add_in_form]
    c.bbar             = []
    c.tools            = false
    c.multi_select     = false
    c.prohibit_update  = true
    c.columns          = [
      column_defaults.merge(:name => :username,                 :text => "Username",                  :width => 120),
      column_defaults.merge(:name => :email,                    :text => "Email",                     :flex => true),
      column_defaults.merge(:name => :password,                 :text => "Password",                  :hidden => true,  :editor => {:input_type => :password}),
      column_defaults.merge(:name => :receives_notifications,   :text => "Receives notifications?",   :width => 80,     :hidden => true),
      column_defaults.merge(:name => :is_enabled,               :text => "Enabled?",                  :width => 80,     :align => :center),
      column_defaults.merge(:name => :is_admin,                 :text => "Admin?",                    :width => 80,     :align => :center)
    ]
  end

end
