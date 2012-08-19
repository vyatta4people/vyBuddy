class VyattaHostsBulkAddWindow < Netzke::Basepack::Window

  js_mixin :init_component
  js_mixin :actions

  action :bulk_add, :icon => :server_bulk_add, :text => "Go!", :tooltip => "Go! Go! Go!"

  def configuration
    super.merge(
      :name             => :vyatta_hosts_bulk_add_window,
      :title            => "::Bulk add Vyatta hosts::",
      :border           => true,
      :width            => 450,
      :height           => 550,
      :y                => 50,
      :modal            => true,
      :close_action     => :hide,
      :resizable        => false,
      :items            => [ {
        :id               => :vyatta_hosts_bulk_add_form,
        :xtype            => :form,
        :prevent_header   => true,
        :border           => true,
        :margin           => 5,
        :frame            => false,
        :buttons          => [ :bulk_add.action ],
        :default_type     => :textfield,
        :defaults         => { :anchor => "100%", :label_width => 100, :label_align => :left, :label_pad => 10, :allow_blank => false, :margin => 10 },
        :items            => [ { 
          :name           => :ssh_connection_settings,
          :xtype          => :fieldset,
          :title          => "SSH connection settings",
          :default_type   => :textfield,
          :defaults       => { :anchor => "100%", :label_width => 110, :label_align => :left, :label_pad => 10, :allow_blank => false, :margin => 10 },
          :style          => { :background_color => "#f7f7f7" },
          :items => [ {
            :name         => :ssh_connection_username,
            :field_label  => "SSH username"
          }, {
            :name         => :ssh_connection_password,
            :field_label  => "SSH password",
            :input_type   => :password
          }, {
            :name         => :ssh_connection_hint,
            :xtype        => :displayfield,
            :field_width  => 0,
            :label_pad    => 0,
            :value => "<div class=\"form-hint\">Entered settings are used to establish SSH connection for public key installation and will be forgotten after execution!</div>"
          } ]
        }, {
          :name           => :vyatta_host_installation_settings,
          :xtype          => :fieldset,
          :title          => "Vyatta host installation settings",
          :default_type   => :textfield,
          :defaults       => { :anchor => "100%", :label_width => 110, :label_align => :left, :label_pad => 10, :allow_blank => false, :margin => 10 },
          :style          => { :background_color => "#f7f7f7" },
          :items => [{
            :name         => :ssh_key_pair,
            :field_label  => "SSH public key",
            :xtype        => :combobox,
            :editable     => false,
            :query_mode   => :local,
            :store        => Array.new
          }, {
            :name         => :probe_hostname,
            :field_label  => "Probe hostname?",
            :xtype        => :checkbox
          }, {
            :name         => :vyatta_host_group,
            :field_label  => "Vyatta host group",
            :xtype        => :combobox,
            :editable     => false,
            :query_mode   => :local,
            :store        => Array.new
          }, {
            :name         => :hosts,
            :field_label  => "Hosts (one per line)",
            :xtype        => :textarea,
            :height       => 150
          } ]
        } ]
      } ]
    )
  end

  endpoint :get_form_combo_options do |params|
    case params[:field]
    when "ssh_key_pair"
      return { :set_result => SshKeyPair.all.collect {|s| [s.identifier]} }
    when "vyatta_host_group"
      return { :set_result => VyattaHostGroup.enabled.collect {|s| [s.name]} }
    end
  end

  endpoint :bulk_add_vyatta_hosts do |params|
    Log.application     = :bulk_add
    Log.event_source    = "localhost"
    Log.info("Bulk add started")

    ssh_username        = params[:ssh_connection_username]
    ssh_password        = params[:ssh_connection_password]
    ssh_key_pair        = SshKeyPair.find(:first, :conditions => {:identifier => params[:ssh_key_pair]})
    probe_hostname      = params[:probe_hostname]
    vyatta_host_group   = VyattaHostGroup.find(:first, :conditions => {:name => params[:vyatta_host_group]})
    hosts               = params[:hosts].split("\n").uniq; hosts.delete_if { |h| h.match(/^ *$/) }

    results = Array.new
    hosts.each do |remote_address|
      hostname                    = remote_address
      Log.event_source            = hostname

      success                     = false
      message                     = ""
      vyatta_host                 = VyattaHost.new
      vyatta_host.remote_address  = remote_address
      vyatta_host.ssh_username    = ssh_username
      vyatta_host.ssh_password    = ssh_password
      if vyatta_host.check_reachability and vyatta_host.verify_executors([:system, :operational], true)
        if vyatta_host.vyatta?
          if probe_hostname
            vyatta_host.hostname          = vyatta_host.get_hostname
            hostname                      = hostname + " (#{vyatta_host.hostname})"
          else
            vyatta_host.hostname          = remote_address
          end
          vyatta_host.ssh_key_pair        = ssh_key_pair
          vyatta_host.vyatta_host_group   = vyatta_host_group
          if vyatta_host.save
            vyatta_host.vyatta_host_state.vyatta_version  = vyatta_host.get_vyatta_version
            vyatta_host.vyatta_host_state.load_average    = vyatta_host.get_load_average
            vyatta_host.vyatta_host_state.save
            if vyatta_host.verify_executors([:configuration], true)
              remote_commands = Array.new
              remote_commands << { :mode => :configuration, :command => "begin" }
              remote_commands << { :mode => :configuration, :command => "set system login user #{vyatta_host.ssh_key_pair.login_username} authentication public-keys #{vyatta_host.ssh_key_pair.identifier} type #{vyatta_host.ssh_key_pair.key_type}" }
              remote_commands << { :mode => :configuration, :command => "set system login user #{vyatta_host.ssh_key_pair.login_username} authentication public-keys #{vyatta_host.ssh_key_pair.identifier} key  #{vyatta_host.ssh_key_pair.public_key}" }
              user_exists = vyatta_host.user_exists?(vyatta_host.ssh_key_pair.login_username)
              if !user_exists
                remote_commands << { :mode => :configuration, :command => "set system login user #{vyatta_host.ssh_key_pair.login_username} authentication plaintext-password #{vyatta_host.ssh_password}" }
              end
              remote_commands << { :mode => :configuration, :command => "commit" }
              remote_commands << { :mode => :configuration, :command => "save" }
              remote_commands << { :mode => :configuration, :command => "end" }
              result_sets = vyatta_host.execute_remote_commands(remote_commands, true)
              if result_sets
                success = true
                if user_exists
                  message = "Updated existing user: #{vyatta_host.ssh_key_pair.login_username}"
                else
                  message = "Created new user: #{vyatta_host.ssh_key_pair.login_username}"
                end
              else
                message = vyatta_host.ssh_error
              end
            else
              message = "Unable to verify configuration mode executor"
            end
          else
            message = vyatta_host.errors.full_messages.join(', ')
          end
        else
          message = "Not a Vyatta system"
        end
      else
        message = vyatta_host.ssh_error
      end

      result      = Array.new
      result[0]   = hostname
      result[1]   = success
      result[2]   = HTMLEntities.new.encode(message)
      results << result

      if success
        Log.info(message)
      else
        Log.error(message)
      end
    end

    Log.event_source = "localhost"
    Log.info("Bulk add finished")

    return { :set_result => results }
  end

end