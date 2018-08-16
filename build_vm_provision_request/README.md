This is a simplified version of the build_vm_provision_request.rb from Kevin Morey's CloudForms Essentials (https://github.com/ramrexx/CloudForms_Essentials).

add_to_service.rb can be called from a VM provisioning state machine to add the VM to the service.

check_vm_provision_request.rb can be called from a service provisioning state machine to cause it to wait for associated VM provisions to complete.  This is useful to prevent service provisions from succeeding when VM provisions do not and can also be used to cause the service provision to wait for VM provisions to finish before executing some common task amongst all of the associated VMs etc.
