class SshKeyPairsGrid < Netzke::Basepack::GridPanel

  action :add_in_form,  :text => "Add",  :tooltip => "Add SSH public/private key pair"
  action :edit_in_form, :text => "Edit", :tooltip => "Edit SSH public/private key pair"

  def configuration
    column_defaults                 = Hash.new
    column_defaults[:editable]      = false
    column_defaults[:sortable]      = false
    column_defaults[:menu_disabled] = true
    column_defaults[:resizable]     = false
    column_defaults[:draggable]     = false
    column_defaults[:fixed]         = true

    form_window_config              = Hash.new
    form_window_config[:width]      = 800
    form_window_config[:height]     = 700

    super.merge(
      :name             => :ssh_key_pairs_grid,
      :title            => "SSH public/private key pairs",
      :prevent_header   => true,
      :model            => "SshKeyPair",
      :scope            => lambda { |s| s.sorted },
      :border           => true,
      :context_menu     => [:edit_in_form.action, :del.action],
      :tbar             => [:add_in_form.action],
      :bbar             => [],
      :tools            => false,
      :multi_select     => false,
      :columns          => [
        column_defaults.merge(:name => :user__username,     :text => "Owner",         :hidden => true,  :default_value => User.first ? User.first.id : nil),
        column_defaults.merge(:name => :identifier,         :text => "ID",            :flex => true),
        column_defaults.merge(:name => :key_type,           :text => "Type",          :width => 80, :editor => {:xtype => :netzkeremotecombo}, :align => :center),
        column_defaults.merge(:name => :login_username,     :text => "Login as",      :width => 100),
        column_defaults.merge(:name => :public_key,         :text => "Public key",    :hidden => true, :editor => {:height => 100}),
        column_defaults.merge(:name => :private_key,        :text => "Private key",   :hidden => true, :editor => {:height => 400})
      ],
      :add_form_window_config   => form_window_config.merge(:title => "Add SSH public/private key pair"),
      :edit_form_window_config  => form_window_config.merge(:title => "Edit SSH public/private key pair")
    )
  end

  def get_combobox_options(params)
    case params[:column]
    when "key_type"
      return { :data => SSH_KEY_TYPES.collect {|t| [t, t]} }
    end
    super
  end

  endpoint :add_form__netzke_0__get_combobox_options do |params|
    get_combobox_options(params)
  end

  endpoint :add_form__netzke_0__get_combobox_options do |params|
    get_combobox_options(params)
  end

end
