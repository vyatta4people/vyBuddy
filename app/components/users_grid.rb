class UsersGrid < Netzke::Basepack::GridPanel

  action :add_in_form,  :text => "Add",  :tooltip => "Add user"
  action :edit_in_form, :text => "Edit", :tooltip => "Edit user"

  def configuration
    column_defaults                 = Hash.new
    column_defaults[:editable]      = false
    column_defaults[:sortable]      = false
    column_defaults[:menu_disabled] = true
    column_defaults[:resizable]     = false
    column_defaults[:draggable]     = false
    column_defaults[:fixed]         = true

    super.merge(
      :name             => :users_grid,
      :title            => "Users",
      :prevent_header   => true,
      :model            => "User",
      :scope            => lambda { |s| s.sorted },
      :border           => true,
      :context_menu     => [:edit_in_form.action, :del.action],
      :tbar             => [:add_in_form.action],
      :bbar             => [],
      :tools            => false,
      :multi_select     => false,
      :columns          => [
        column_defaults.merge(:name => :username,           :text => "Username",  :width => 120),
        column_defaults.merge(:name => :email,              :text => "Email",     :flex => true),
        column_defaults.merge(:name => :password,           :text => "Password",  :hidden => true,  :editor => {:input_type => :password}),
        column_defaults.merge(:name => :is_enabled,         :text => "Enabled?",  :width => 80,     :align => :center),
        column_defaults.merge(:name => :is_admin,           :text => "Admin?",    :width => 80,     :align => :center)
      ]
    )
  end

end
