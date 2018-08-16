###################################
#
# CFME Automate Method: Add_VM_To_Service
#
# Notes: This method adds a VM to an existing service
#        This method is also being used to ensure that the Service_Offering_Part number contains the final vm.name.
#
# Inputs: ws_values[:service_id]
#
###################################
begin
  # Method for logging
  def log(level, message)
    @method = 'Add_VM_To_Service'
    $evm.log(level, "#{@method} - #{message}")
  end

  # dump_root
  def dump_root()
    log(:info, "Root:<$evm.root> Begin $evm.root.attributes")
    $evm.root.attributes.sort.each { |k, v| log(:info, "Root:<$evm.root> Attribute - #{k}: #{v}")}
    log(:info, "Root:<$evm.root> End $evm.root.attributes")
    log(:info, "")
  end

  log(:info, "CFME Automate Method Started")

  # dump all root attributes to the log
  dump_root

  # Get miq_provision from root
  prov = $evm.root['miq_provision']
  raise "miq_provision object not found" if prov.nil?
  log(:info, "Provision:<#{prov.id}> Request:<#{prov.miq_provision_request.id}> Type:<#{prov.type}>")

  vm = prov.vm
  raise "$evm.root['miq_provision'].vm not found" if prov.vm.nil?

  prov_tags = prov.get_tags
  log(:info, "Inspecting miq_provision tags:<#{prov_tags.inspect}>")

  if prov.options.has_key?(:ws_values)
    ws_values = prov.options[:ws_values]
    unless ws_values[:service_id].blank?

      # Look up the flex service parent by prov.options[:ws_values][:serviceflex_service_id]
      parent_service = $evm.vmdb('service').find_by_id(ws_values[:service_id])
      raise "Parent service id:<#{ws_values[:serviceflex_service_id]}> not found" if parent_service.nil?
      log(:info, "Service:<#{parent_service.name}> vms:<#{parent_service.vms.count}> tags:<#{parent_service.tags.inspect}>")

      # Add vm to the parent service
      log(:info, "Adding VM:<#{vm.name}> to parent service:<#{parent_service.name}>")
      vm.add_to_service(parent_service)
      log(:info, "Service:<#{parent_service.name}> vms:<#{parent_service.vms.count}> tags:<#{parent_service.tags.inspect}>")

      # Ensure final VM name (post IPAM acquire) is set in Service_Offering_Part_#
      parent_service.custom_set("Service_Offering_Part_#{ws_values[:build_part]}".to_sym , vm.name)

      # Save the server_vlan as a custom attribute for use during retirement.
      # This enables us to release IP's for VMs not provisioned by CloudForms assuming the custom attribute is added to the VM object.
      #vm.custom_set(:server_vlan, ws_values[:server_vlan])

    end
  end

  # Exit method
  log(:info, "CFME Automate Method Ended")
  exit MIQ_OK

  # Ruby rescue
rescue => err
  log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_STOP
end

