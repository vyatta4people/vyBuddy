class SshKeyPairsGrid < Netzke::Basepack::Grid

  js_configure do |c|
    c.mixin :main
  end

  action :add_in_form do |a|
    a.text      = "Add"
    a.tooltip   = "Add SSH public/private key pair"
    a.icon      = :key_add
  end

  action :edit_in_form do |a|
    a.text      = "Examine"
    a.tooltip   = "Edit SSH public/private key pair"
    a.icon      = :key
    a.disabled  = false
  end

  action :del do |a|
    a.icon      = :key_delete
  end

  def configure(c)
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

    super
    c.name             = :ssh_key_pairs_grid,
    c.title            = "SSH public/private key pairs",
    c.prevent_header   = true,
    c.model            = "SshKeyPair",
    c.border           = true,
    c.context_menu     = [:edit_in_form, :del],
    c.tbar             = [:add_in_form],
    c.bbar             = [],
    c.tools            = false,
    c.multi_select     = false,
    c.prohibit_update  = true,
    c.columns          = [
      column_defaults.merge(:name => :user__username,     :text => "Owner",         :hidden => true,
        :editor => {:editable => false, :empty_text => "Choose user"}),
      column_defaults.merge(:name => :identifier,         :text => "ID",            :flex => true),
      column_defaults.merge(:name => :key_type,           :text => "Type",          :width => 80,
        :editor => {:xtype => :netzkeremotecombo, :editable => false, :empty_text => "Choose SSH key type" }, :align => :center),
      column_defaults.merge(:name => :login_username,     :text => "Login as",      :width => 100, :default_value => Setting.get(:default_ssh_username)),
      column_defaults.merge(:name => :public_key,         :text => "Public key",    :hidden => true,
        :editor => {
          :height         => 100,
          :disabled       => true,
          :disabled_cls   => "x-form-empty-field",
          :empty_text     => "NB! Do not enter public key manually, it will be generated from your private key!"
         }
      ),
      column_defaults.merge(:name => :private_key,        :text => "Private key",   :hidden => true, :editor => {:height => 225})
    ]
  end

  def get_combobox_options(params)
    case params[:column]
    when "user__username"
      return { :data => User.enabled.collect {|u| [u.id, u.username]} }
    when "key_type"
      return { :data => SSH_KEY_TYPES.collect {|t| [t, t]} }
    end
  end

  endpoint :add_form__netzke_0__get_combobox_options do |params, this|
    this.netzke_set_result(get_combobox_options(params))
  end

  endpoint :edit_form__netzke_0__get_combobox_options do |params, this|
    this.netzke_set_result(get_combobox_options(params))
  end

end