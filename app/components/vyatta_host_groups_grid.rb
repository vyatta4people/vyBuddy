class VyattaHostGroupsGrid < Netzke::Basepack::Grid

  js_configure do |c|
    c.mixin :main, :methods
  end

  action :add_in_form do |a|
    a.text      = "Add"
    a.tooltip   = "Add host group"
  end

  action :edit_in_form do |a|
    a.text      = "Edit"
    a.tooltip   = "Edit host group"
    a.disabled  = false
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
    c.name = :vyatta_host_groups_grid
    c.title = "Host groups"
    c.model = "VyattaHostGroup"
    c.load_inline_data = false
    c.border = false
    c.context_menu = [:edit_in_form, :del]
    c.tbar = [:add_in_form]
    c.bbar = []
    c.tools = false
    c.multi_select = false
    c.prohibit_update = true
    c.view_config = {
        :plugins => [ { :ptype => :gridviewdragdrop, :dd_group => :vyatta_host_groups_dd_group, :drag_text => "Drag and drop to reorganize or send to task details area" } ]
      }
    c.columns = [
        column_defaults.merge(:name => :name,                     :text => "Name",            :hidden => true),
        column_defaults.merge(:name => :html_name,                :text => "Name",            :flex => true, :renderer => 'boldRenderer', :editor => {:hidden => true}, :virtual => true),
        column_defaults.merge(:name => :color,                    :text => "Color",           :hidden => true),
        column_defaults.merge(:name => :sort_order,               :text => "#",               :width => 40, :align => :center, :renderer => "textSteelBlueRenderer", :editor => {:hidden => true}),
        column_defaults.merge(:name => :is_enabled,               :text => "Enabled?",        :hidden => true)
      ]
  end

  endpoint :reorganize_with_persistent_order do |params, this|
    moved_vyatta_host_group     = VyattaHostGroup.find(params[:moved_record_id].to_i)
    replaced_vyatta_host_group  = VyattaHostGroup.find(params[:replaced_record_id].to_i)
    position                    = params[:position].to_sym
    success                     = VyattaHostGroup.reorganize_with_persistent_order(moved_vyatta_host_group, replaced_vyatta_host_group, position)
    this.netzke_set_result({ :success => success, :message => VyattaHostGroup.reorganize_with_persistent_order_message })
  end

  endpoint :delete_data do |params, this|
    if !config[:prohibit_delete]
      record_ids = ActiveSupport::JSON.decode(params[:records])
      data_class.destroy(record_ids)
      on_data_changed
      this.netzke_feedback(I18n.t('netzke.basepack.grid_panel.deleted_n_records', :n => record_ids.size))
      this.after_delete(get_data)
    else
      this.netzke_feedback(I18n.t('netzke.basepack.grid_panel.cannot_delete'))
    end
  end

  endpoint :reorder_records do |params, this|
    records           = VyattaHostGroup.all
    reordered_records = VyattaHostGroup.reorder_records(records)
    success           = !reordered_records.nil? and !reordered_records.empty? ? true : false
    message           = VyattaHostGroup.reorder_records_message
    this.netzke_set_result({ :success => success, :message => message })
  end

end
