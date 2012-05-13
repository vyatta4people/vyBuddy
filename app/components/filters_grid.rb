class FiltersGrid < Netzke::Basepack::GridPanel

  js_mixin :init_component

  action :add_in_form,  :text => "Add",  :tooltip => "Add filter",  :icon => :script_add
  action :edit_in_form, :text => "Edit", :tooltip => "Edit filter", :icon => :script_edit, :disabled => false
  action :del, :icon => :script_delete

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
    form_window_config[:width]      = 700
    form_window_config[:height]     = 500

    super.merge(
      :name             => :filters_grid,
      :title            => "Filters",
      :model            => "Filter",
      :border           => false,
      :context_menu     => [:edit_in_form.action, :del.action],
      :tbar             => [:add_in_form.action],
      :bbar             => [],
      :tools            => false,
      :multi_select     => false,
      :prohibit_update  => true,
      :columns          => [
        column_defaults.merge(:name => :name,               :text => "Name",          :flex => true),
        column_defaults.merge(:name => :interpreter,        :text => "Interpreter",   :editor => {:xtype => :netzkeremotecombo, :editable => false}),
        column_defaults.merge(:name => :code,               :text => "Code",          :hidden => true, :editor => {:height => 350, :field_cls => 'code-editor'})
      ],
      :add_form_window_config   => form_window_config.merge(:title => "Add scriptable filter"),
      :edit_form_window_config  => form_window_config.merge(:title => "Edit scriptable filter")
    )
  end

  def get_combobox_options(params)
    case params[:column]
    when "interpreter"
      return { :data => INTERPRETERS.collect {|i| [i, i]} }
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
