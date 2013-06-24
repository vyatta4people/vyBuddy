class ImportExportWindow < Netzke::Basepack::Window

  js_configure do |c|
    c.mixin :main, :actions
  end

  action :import_export do |a|
    a.icon    = :import_export
    a.text    = "Import!"
    a.tooltip = "Import/Export"
  end

  def get_form_items
    form_items          = Array.new

    object_filter_items = Array.new
    PORTABLE_CLASSES.each { |c| object_filter_items << { :name => c, :item_id => c, :field_label => c.to_s.humanize.pluralize, :hidden => c == :task_remote_command } }
    form_items << {
      :xtype          => :fieldset,
      :item_id        => :object_filter,
      :title          => "Object filter",
      :style          => { :background_color => "#f7f7f7" },
      :items          => [ {
        :xtype          => :checkboxgroup,
        :item_id        => :object_types,
        :defaults       => { :label_width => 180, :label_align => :right, :label_pad => 10, :margin => 10, :checked => true },
        :columns        => 1,
        :vertical       => true,
        :allow_blank    => false,
        :items          => object_filter_items
      } ]
    }

    form_items << {
      :xtype          => :fieldset,
      :item_id        => :action_picker,
      :title          => "Action picker",
      :defaults       => { :anchor => "100%", :label_pad => 10, :margin => 10, :allow_blank => false },
      :style          => { :background_color => "#f7f7f7" },
      :items          => [ {
        :xtype          => :combobox,
        :name           => :action_type,
        :item_id        => :action_type,
        :field_label    => "",
        :label_width    => 0,
        :editable       => false,
        :query_mode     => :local,
        :store          => [ [:import, "Import objects from JSON file"], [:export, "Export objects to JSON file"] ]
      }, {
        :xtype          => :filefield,
        :name           => :import_file,
        :item_id        => :import_file,
        :field_label    => "File",
        :label_align    => :top
      } ]
    }

    return form_items
  end

  def configure(c)
    super
    c.item_id          = :import_export_window
    c.title            = "::Import/Export::"
    c.width            = 300
    c.height           = 430
    c.y                = 50
    c.modal            = true
    c.close_action     = :hide
    c.resizable        = false
    c.items            = [ {
                             :xtype            => :form,
                             :item_id          => :import_export_form,
                             :prevent_header   => true,
                             :border           => true,
                             :margin           => 5,
                             :frame            => false,
                             :buttons          => [ :import_export ],
                             :defaults         => { :anchor => "100%", :margin => 10 },
                             :items            => get_form_items
                           } ]

  end

  endpoint :load_object_selection do |params|
    success           = false
    action_type       = params.delete(:action_type).to_sym

    # TaskRemoteCommand is a special object type, we do not handle it directly
    if params[:task_remote_command].to_b
      params.delete(:task_remote_command)
      task_remote_command = true
    else
      task_remote_command = false
    end

    # Now handle "normal" object types
    data          = Array.new
    object_types  = params.select{ |k, v| v.to_b if PORTABLE_CLASSES.include?(k.to_sym) }.keys.collect{ |k| eval(k.camelize) }
    if action_type == :import
      importable_objects = params[:import_file_json]["data"]
      importable_objects.keys.each do |object_type|
        importable_objects[object_type].each do |o|
          if object_type == "RemoteCommand"
            name = o["mode"] + "::" + o["command"]
          else
            name = o["name"]
          end
          data << [ object_type, object_type.underscore.humanize, o["id"], name, true ] if object_types.include?(eval(object_type))
        end
      end
    else
      object_types.each do |object_type|
        data += object_type.all.collect{ |o| [ object_type.name, object_type.name.underscore.humanize, o.id, o.name, true ] }
      end
    end

    this.netzke_set_result({ :success => success, :action_type => action_type, :data => data, :task_remote_command => task_remote_command, :import_file_json => params[:import_file_json].to_s })
  end

end
