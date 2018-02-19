###################################
# CFME Automate Method: dump_tags.rb
# Notes: This method writes obj tag data to file.
#
###################################


begin

  # For use via rails runner.
  $evm = MiqAeMethodService::MiqAeService.new(MiqAeEngine::MiqAeWorkspaceRuntime.new)

  # Method for logging
  def log(level, message)
    @method = 'dump_tags'
    puts "#{@method} - #{message}"
  end

  #################################
  # Method: writeToFile
  # Notes: puts each obj in a new line
  #################################
  def writeToFile(target, aLine)
    target.puts(aLine)
  end

  def dumper(obj_type)
    search = obj_type
    search = 'vm_or_template' if obj_type == 'vm'
    file = "/var/www/miq/vmdb/tmp/tag_#{obj_type}.data"
    log(:info, "Dumping #{search} tags to #{file}")

    # Open file
    filetarget = File.open(file, "w+")

    # get obj_type information to send
    $evm.vmdb(search).all.each do |v|

      obj_name = v.name

      obj_tags = v.tags
      obj_tags.delete_if { |tag| tag.include? 'folder_path_yellow' }
      obj_tags.delete_if { |tag| tag.include? 'folder_path_blue' }
      obj_tags_str = obj_tags.join(',')

      # Write to file
      writeToFile(filetarget, "#{obj_type}_name=#{obj_name}|#{obj_type}_tags=#{obj_tags_str}")
    end
    # Close file
    filetarget.close
  end

  log(:info, "Method Started")

  ARGV.each do |i|
    dumper(i)
  end

  # Exit method
  log(:info, "Method Ended")
  exit

    # Set Ruby rescue behavior
rescue => err
  log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit
end
