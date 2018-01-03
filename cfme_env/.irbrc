# limit output size in IRB console.
# From https://github.com/georgegoh/cloudforms-util
#
class IRB::Context
   attr_accessor :max_output_size

   alias initialize_before_max_output_size initialize
   def initialize(*args)
     initialize_before_max_output_size(*args)
     @max_output_size = IRB.conf[:MAX_OUTPUT_SIZE] || 300
   end
end

class IRB::Irb
   def output_value
     text =
       if @context.inspect?
         sprintf @context.return_format, @context.last_value.inspect
       else
         sprintf @context.return_format, @context.last_value
       end
     max = @context.max_output_size
     if text.size < max
       puts text
     else
       puts text[0..max-1] + "..." + text[-2..-1]
     end
   end
end

def get_evm
    # Retrieve a new EVM object and set it to the $evm attribute.
    ws = MiqAeEngine::MiqAeWorkspaceRuntime.new
    ws.ae_user = User.where(:userid => 'admin').first
    MiqAeMethodService::MiqAeService.new(ws)
end

$evm = get_evm

# Lower logging level.
ActiveRecord::Base.logger.level = 1
