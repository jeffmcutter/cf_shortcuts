=begin
  build_vm_provision_request.rb

  Original Author: Kevin Morey <kevin@redhat.com>
  Reduced to more basic functionality by: Jeffrey Cutter <jcutter@redhat.com>

  Inputs: dialog_option_[0-9]_guid, dialog_option_[0-9]_flavor, dialog_tag_[0-9]_environment, etc...
-------------------------------------------------------------------------------
   Copyright 2016 Kevin Morey <kevin@redhat.com>

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
-------------------------------------------------------------------------------
=end

begin

  def log(level, msg, update_message = false)
    $evm.log(level, "#{msg}")
    @task.message = msg if @task && (update_message || level == 'error')
  end

  # create the categories and tags
  def create_tags(category, single_value=true, tag)
    log(:info, "Processing create_tags...", true)
    # Convert to lower case and replace all non-word characters with underscores
    category_name = category.to_s.downcase.gsub(/\W/, '_')
    tag_name = tag.to_s.downcase.gsub(/\W/, '_')

    unless $evm.execute('category_exists?', category_name)
      log(:info, "Category #{category_name} doesn't exist, creating category")
      $evm.execute('category_create', :name=>category_name, :single_value=>single_value, :description=>"#{category}")
    end
    # if the tag exists else create it
    unless $evm.execute('tag_exists?', category_name, tag_name)
      log(:info, "Adding new tag #{tag_name} in Category #{category_name}")
      $evm.execute('tag_create', category_name, :name => tag_name, :description => "#{tag}")
    end
    log(:info, "Processing create_tags...Complete", true)
  end

  def process_tag(tag_category, tag_value)
    return if tag_value.blank?
    create_tags(tag_category, true, tag_value)
  end

  # fix_dialog_tags_hash to allow for support of Tag Control items in dialogs.  Previously, the Tag Control would
  # push values in as an array, which is not supported.  The fix_dialog_tag_hash parsed the dialog_tags_hash and changes
  # all array values to strings.
  def fix_dialog_tags_hash(dialog_tags_hash)
    unless dialog_tags_hash.empty?
      dialog_tags_hash.each do |build_num,build_tags_hash|
        build_tags_hash.each do |k,v|
          if v.is_a?(Array)
            log(:info, "fix_dialog_tags_hash: Build #{build_num}: updating key <#{k}> with array value <#{v}> to <#{v.first}>")
            build_tags_hash[k] = v.first if v.is_a?(Array)
          end
        end
      end
    end
    dialog_tags_hash
  end

  def yaml_data(option)
    @task.get_option(option).nil? ? nil : YAML.load(@task.get_option(option))
  end

  # check to ensure that dialog_parser has ran
  def parsed_dialog_information
    dialog_options_hash = yaml_data(:parsed_dialog_options)
    dialog_tags_hash = yaml_data(:parsed_dialog_tags)
    if dialog_options_hash.blank? && dialog_tags_hash.blank?
      log(:info, "Instantiating dialog_parser to populate dialog options")
      $evm.instantiate('/Service/Provisioning/StateMachines/Methods/DialogParser')
      dialog_options_hash = yaml_data(:parsed_dialog_options)
      dialog_tags_hash = yaml_data(:parsed_dialog_tags)
      raise 'Error loading dialog options' if dialog_options_hash.blank? && dialog_tags_hash.blank?
    end
    log(:info, "dialog_options_hash: #{dialog_options_hash.inspect}")
    log(:info, "dialog_tags_hash: #{dialog_tags_hash.inspect}")
    return dialog_options_hash, fix_dialog_tags_hash(dialog_tags_hash)
  end

  def merge_service_item_dialog_values(build, dialogs_hash)
    merged_hash = Hash.new { |h, k| h[k] = {} }
    if dialogs_hash[0].nil?
      merged_hash = dialogs_hash[build] || {}
    else
      merged_hash = dialogs_hash[0].merge(dialogs_hash[build] || {})
    end
    merged_hash
  end

  # merge dialog information
  def merge_dialog_information(build, dialog_options_hash, dialog_tags_hash)
    merged_options_hash = merge_service_item_dialog_values(build, dialog_options_hash)
    merged_tags_hash = merge_service_item_dialog_values(build, dialog_tags_hash)
    log(:info, "build: #{build} merged_options_hash: #{merged_options_hash.inspect}")
    log(:info, "build: #{build} merged_tags_hash: #{merged_tags_hash.inspect}")
    return merged_options_hash, merged_tags_hash
  end

  def get_array_of_builds(dialogs_options_hash)
    builds = []
    dialogs_options_hash.each do |build, options|
      next if build.zero?
      builds << build
    end
    builds.sort
  end

  # determine who the requesting user is
  def get_requester(build, merged_options_hash, merged_tags_hash)
    log(:info, "Processing get_requester...", true)
    @user = $evm.vmdb('user').find_by_id(merged_options_hash[:user_id]) ||
      $evm.root['user']
    merged_options_hash[:user_name]        = @user.userid
    merged_options_hash[:owner_first_name] = @user.first_name ? @user.first_name : 'Cloud'
    merged_options_hash[:owner_last_name]  = @user.last_name ? @user.last_name : 'Admin'
    merged_options_hash[:owner_email]      = @user.email ? @user.email : $evm.object['to_email_address']
    log(:info, "Build: #{build} - User: #{merged_options_hash[:user_name]} " \
        "email: #{merged_options_hash[:owner_email]}")
    # Stuff the current group information
    merged_options_hash[:group_id] = @user.current_group.id
    merged_options_hash[:group_name] = @user.current_group.description
    log(:info, "Build: #{build} - Group: #{merged_options_hash[:group_name]} " \
        "id: #{merged_options_hash[:group_id]}")

    log(:info, "Processing get_requester...Complete", true)
  end

  def get_template(build, merged_options_hash, merged_tags_hash)
    log(:info, "Processing get_template...", true)
    @template = $evm.vmdb(:miq_template).where("guid = '#{merged_options_hash[:guid]}'").first
    log(:info, "Build: #{build} - template: #{@template.name} guid: #{@template.guid} " \
        "on provider: #{@template.ext_management_system.name}")
    merged_options_hash[:name] = @template.name
    merged_options_hash[:guid] = @template.guid
    log(:info, "Processing get_template...Complete", true)
  end

  def get_provision_type(build, merged_options_hash, merged_tags_hash)
    log(:info, "Processing get_provision_type...", true)
    case @template.vendor.downcase
    when 'vmware'
      # Valid types for vmware:  vmware, pxe, netapp_rcu
      if merged_options_hash[:provision_type].blank?
        merged_options_hash[:provision_type] = 'vmware'
      end
    when 'redhat'
      # Valid types for rhev: iso, pxe, native_clone
      if merged_options_hash[:provision_type].blank?
        merged_options_hash[:provision_type] = 'native_clone'
      end
    end
    if merged_options_hash[:provision_type]
      log(:info, "Build: #{build} - provision_type: #{merged_options_hash[:provision_type]}")
    end
    log(:info, "Processing get_provision_type...Complete", true)
  end

  def get_vm_name(build, merged_options_hash, merged_tags_hash)
    log(:info, "Processing get_vm_name", true)
    new_vm_name = merged_options_hash[:vm_name] || merged_options_hash[:vm_target_name]
    proposed_vm_name = nil
    if new_vm_name.include?('*')
      log(:info, "Processing VM name prepended by *")
      raise 'vm_name cannot contain a * when provisioning multiple VMs' if merged_options_hash[:number_of_vms] > 1
      raise "vm_name #{new_vm_name} already exists." if $evm.vmdb(:vm_or_template).find_by_name(new_vm_name.gsub('*', ''))
      proposed_vm_name = new_vm_name
    else
      # Loop through 00-99 and look to see if the vm_name already exists in the vmdb to avoid collisions
      for i in (1..100)
        raise "All VM names used for #{new_vm_name} 00-99" if i == 100
        proposed_vm_name = "#{new_vm_name}#{i.to_s.rjust(2, "0")}"
        log(:info, "Checking for existence of vm: #{proposed_vm_name}")
        if $evm.vmdb(:vm_or_template).find_by_name(proposed_vm_name).blank?
          proposed_vm_name = new_vm_name
          break
        end
      end
    end
    merged_options_hash[:vm_name] = proposed_vm_name
    merged_options_hash[:linux_host_name] = proposed_vm_name
    log(:info, "Build: #{build} - VM Name: #{merged_options_hash[:vm_name]}")
    log(:info, "Processing get_vm_name...Complete", true)
  end

  def get_network(build, merged_options_hash, merged_tags_hash)
    log(:info, "Processing get_network...", true)
    case @template.vendor.downcase
    when 'vmware'
      if merged_options_hash[:vlan].blank?
        # Set a default vlan here
        merged_options_hash[:vlan] = 'VM Network'
      end
    when 'redhat'
      if merged_options_hash[:vlan].blank?
        # Set a default vlan here
        merged_options_hash[:vlan] = 'ovirtmgmt'
      end
    when 'microsoft'
      if merged_options_hash[:vlan].blank? && merged_tags_hash[:ipam_path]
        merged_options_hash[:vlan] = merged_tags_hash[:ipam_path]
      end
    end
    log(:info, "Build: #{build} - vlan: #{merged_options_hash[:vlan]}")
    log(:info, "Processing get_network...Complete", true)
  end

  def get_flavor(build, merged_options_hash, merged_tags_hash)
    log(:info, "Processing get_flavor...", true)
    merged_options_hash[:number_of_sockets] = 1
    # Rest from dialog.
    #merged_options_hash[:cores_per_socket]  = cores_per_socket
    #merged_options_hash[:vm_memory]         = vm_memory
    log(:info, "Processing get_flavor...Complete", true)
  end

  def get_extra_options(build, merged_options_hash, merged_tags_hash)
    log(:info, "Processing get_extra_options...", true)
    # stuff the service guid & id so that the VMs can be added to the service later (see AddVMToService)
    merged_options_hash[:service_id] = @service.id unless @service.nil?
    merged_options_hash[:service_guid] = @service.guid unless @service.nil?
    log(:info, "Build: #{build} - service_id: #{merged_options_hash[:service_id]} " \
        "service_guid: #{merged_options_hash[:service_guid]}")
    log(:info, "Processing get_extra_options...Complete", true)
  end

  def process_builds(dialog_options_hash, dialog_tags_hash)
    builds = get_array_of_builds(dialog_options_hash)
    log(:info, "builds: #{builds.inspect}")
    builds.each do |build|
      merged_options_hash, merged_tags_hash = merge_dialog_information(build, dialog_options_hash, dialog_tags_hash)

      # get requester (figure out who the requester/user is)
      get_requester(build, merged_options_hash, merged_tags_hash)

      # get template (search for an available template)
      get_template(build, merged_options_hash, merged_tags_hash)

      # get the provision type (for vmware, rhev, msscvmm only)
      get_provision_type(build, merged_options_hash, merged_tags_hash)

      # get vm_name (either generate a vm name or use defaults)
      get_vm_name(build, merged_options_hash, merged_tags_hash)

      # get vLAN, cloud_network, security group, keypair information
      get_network(build, merged_options_hash, merged_tags_hash)

      # get cpu and memory (set the flavor)
      get_flavor(build, merged_options_hash, merged_tags_hash)

      #If retirement is set to 0 never retire
      if merged_options_hash[:retirement] == '0'
        merged_options_hash[:retirement] = nil
      else
        merged_options_hash[:retirement] = merged_options_hash[:retirement].days
      end

      # get extra options ( use this section to override any options/tags that you want)
      get_extra_options(build, merged_options_hash, merged_tags_hash)

      # create all specified categories/tags again just to be sure we got them all
      merged_tags_hash.each do |key, value|
        log(:info, "Processing tag: #{key.inspect} value: #{value.inspect}")
        tag_category = key.downcase
        Array.wrap(value).each do |tag_entry|
          process_tag(tag_category, tag_entry.downcase)
        end
      end

      # log each build's tags and options
      log(:info, "Build: #{build} - merged_tags_hash: #{merged_tags_hash.inspect}")
      log(:info, "Build: #{build} - merged_options_hash: #{merged_options_hash.inspect}")

      # call build_provision_request using merged_options_hash and merged_tags_hash to send
      # the payload to miq_request and miq_provision
      request = build_provision_request(build, merged_options_hash, merged_tags_hash)
      log(:info, "Build: #{build} - VM Provision request #{request.id} for " \
          "#{merged_options_hash[:vm_name]} successfully submitted", true)
    end
  end

  def set_valid_provisioning_args
    # set provisioning dialog fields everything not listed below will get stuffed into :ws_values
    valid_templateFields    = [:name, :request_type, :guid, :cluster]

    valid_vmFields          = [:vm_name, :number_of_vms, :vm_description, :vm_prefix]
    valid_vmFields         += [:number_of_sockets, :cores_per_socket, :vm_memory, :mac_address]
    valid_vmFields         += [:root_password, :provision_type, :linux_host_name, :vlan, :customization_template_id]
    valid_vmFields         += [:retirement, :retirement_warn, :placement_auto, :vm_auto_start]
    valid_vmFields         += [:linked_clone, :network_adapters, :placement_cluster_name, :request_notes]
    valid_vmFields         += [:monitoring, :floating_ip_address, :placement_availability_zone, :guest_access_key_pair]
    valid_vmFields         += [:security_groups, :cloud_tenant, :cloud_network, :cloud_subnet, :instance_type]

    valid_requester_args    = [:user_name, :owner_first_name, :owner_last_name, :owner_email, :auto_approve]
    return valid_templateFields, valid_vmFields, valid_requester_args
  end

  def build_provision_request(build, merged_options_hash, merged_tags_hash)
    log(:info, "Processing build_provision_request...", true)
    valid_templateFields, valid_vmFields, valid_requester_args = set_valid_provisioning_args

    # arg1 = version
    args = ['1.1']

    # arg2 = templateFields
    template_args = {}
    merged_options_hash.each { |k, v| template_args[k.to_s] = v.to_s if valid_templateFields.include?(k) }
    valid_templateFields.each { |k| merged_options_hash.delete(k) }
    args << template_args

    # arg3 = vmFields
    vm_args = {}
    merged_options_hash.each { |k, v| vm_args[k.to_s] = v.to_s if valid_vmFields.include?(k) }
    valid_vmFields.each { |k| merged_options_hash.delete(k) }
    args << vm_args

    # arg4 = requester
    requester_args = {}
    merged_options_hash.each { |k, v| requester_args[k.to_s] = v.to_s if valid_requester_args.include?(k) }
    valid_requester_args.each { |k| merged_options_hash.delete(k) }
    args << requester_args

    # arg5 = tags
    tag_args = {}
    merged_tags_hash.each { |k, v| tag_args[k.to_s] = v.to_s }
    args << tag_args

    # arg6 = Aditional Values (ws_values)
    # put all remaining merged_options_hash and merged_tags_hash in ws_values hash for later use in the state machine
    ws_args = {}
    merged_options_hash.each { |k, v| ws_args[k.to_s] = v.to_s }
    args << ws_args.merge(tag_args)

    # arg7 = emsCustomAttributes
    args << nil

    # arg8 = miqCustomAttributes
    args << nil

    log(:info, "Build: #{build} - Building provision request with the following arguments: #{args.inspect}")
    request = $evm.execute('create_provision_request', *args)

    # Reset the global variables for the next build
    @template, @user, = nil, nil
    log(:info, "Processing build_provision_request...Complete", true)
    return request
  end

  # Main.

  $evm.root.attributes.sort.each { |k, v| log(:info, "\t Attribute: #{k} = #{v}")}
  @task = $evm.root['service_template_provision_task']
  @service = @task.destination
  log(:info, "Service: #{@service.name} id: #{@service.id} tasks: #{@task.miq_request_tasks.count}")

  dialog_options_hash, dialog_tags_hash = parsed_dialog_information

  # prepare the builds and execute them
  process_builds(dialog_options_hash, dialog_tags_hash)

rescue => err
  log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  @task['status'] = 'Error' if @task
  @task.finished("#{err}") if @task
  @service.remove_from_vmdb if @service
  exit MIQ_ABORT
end
