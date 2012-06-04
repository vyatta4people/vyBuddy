class SshKeyPairsGrid < Netzke::Basepack::GridPanel

  js_mixin :init_component

  action :add_in_form,  :text => "Add",     :tooltip => "Add SSH public/private key pair",   :icon => :key_add
  action :edit_in_form, :text => "Examine", :tooltip => "Edit SSH public/private key pair",  :icon => :key, :disabled => false
  action :del, :icon => :key_delete

  def configuration
    column_defaults                 = Hash.new
    column_defaults[:editable]      = false
    column_defaults[:sortable]      = false
    column_defaults[:menu_disabled] = true
    column_defaults[:resizable]     = false
    column_defaults[:draggable]     = false
    column_defaults[:fixed]         = true

    form_window_config              = Hash.new
    form_window_config[:y]          = 50
    form_window_config[:width]      = 800
    form_window_config[:height]     = 525

    super.merge(
      :name             => :ssh_key_pairs_grid,
      :title            => "SSH public/private key pairs",
      :prevent_header   => true,
      :model            => "SshKeyPair",
      :border           => true,
      :context_menu     => [:edit_in_form.action, :del.action],
      :tbar             => [:add_in_form.action],
      :bbar             => [],
      :tools            => false,
      :multi_select     => false,
      :prohibit_update  => true,
      :columns          => [
        column_defaults.merge(:name => :user__username,     :text => "Owner",         :hidden => true, 
          :editor => {:editable => false, :empty_text => "Choose user", :listeners => {:change => {:fn => "function(e){e.expand();e.collapse();}".l} } }),
        column_defaults.merge(:name => :identifier,         :text => "ID",            :flex => true),
        column_defaults.merge(:name => :key_type,           :text => "Type",          :width => 80, 
          :editor => {:xtype => :netzkeremotecombo, :editable => false, :empty_text => "Choose SSH key type" }, :align => :center),
        column_defaults.merge(:name => :login_username,     :text => "Login as",      :width => 100, :default_value => Setting.get(:default_ssh_username)),
        column_defaults.merge(:name => :public_key,         :text => "Public key",    :hidden => true, 
          :editor => {
            :height       => 100, 
            :disabled     => true, 
            :disabled_cls  => "x-form-empty-field", 
            :empty_text   => "NB! Do not enter public key manually, it will be generated from your private key!"
          }
        ),
        column_defaults.merge(:name => :private_key,        :text => "Private key",   :hidden => true, :editor => {:height => 225})
      ],
      :add_form_window_config   => form_window_config.merge(:title => "Add SSH public/private key pair"),
      :edit_form_window_config  => form_window_config.merge(:title => "Edit SSH public/private key pair")
    )
  end

  def get_combobox_options(params)
    case params[:column]
    when "user__username"
      return { :data => User.enabled.collect {|u| [u.id, u.username]} }
    when "key_type"
      return { :data => SSH_KEY_TYPES.collect {|t| [t, t]} }
    end
  end

  endpoint :add_form__netzke_0__get_combobox_options do |params|
    get_combobox_options(params)
  end

  endpoint :edit_form__netzke_0__get_combobox_options do |params|
    get_combobox_options(params)
  end

end