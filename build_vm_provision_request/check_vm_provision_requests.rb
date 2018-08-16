#
# CloudForms Method Name: check_vm_provision_requests.rb
#
# Description: Check all VM provision requests from the vm_prov_request_ids state variable and ensure that they are complete before moving on.
#
# jcutter@redhat.com 2017-10-23
#

begin

  def log(level, msg, update_message = false)
    $evm.log(level, "#{msg}")
    @task.message = msg if @task && (update_message || level == 'error')
  end

  # Main.

  @task = $evm.root['service_template_provision_task']
  @service = @task.destination

  vm_prov_request_ids = $evm.get_state_var(:vm_prov_request_ids)

  raise 'State var :vm_prov_request_ids is blank!' if vm_prov_request_ids.blank?

  vm_prov_request_ids.each do |vm_request_id|
    vm_request = $evm.vmdb(:miq_request, vm_request_id)
    unless vm_request.status == 'Ok'
      raise "miq_request #{vm_request_id} has an unexpected status of: #{vm_request.status}, aborting."
    end
    log(:info, "vm_request.state: #{vm_request.state}")
    unless vm_request.state == 'finished'
      interval = '60.seconds'
      log(:info, "Waiting for miq_request #{vm_request_id} to finish.  Will recheck in #{interval}.", true)
      $evm.root['ae_result'] = 'retry'
      $evm.root['ae_retry_interval'] = interval
      exit MIQ_OK
    end
  end

rescue => err
  log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  @task['status'] = 'Error' if @task
  @task.finished("#{err}") if @task
  @service.remove_from_vmdb if @service
  exit MIQ_ABORT
end

