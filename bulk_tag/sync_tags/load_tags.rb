###################################
# CFME Automate Method: load_tags.rb
# Notes: This method loads tag data from file.
#
###################################


begin

  # For use via rails runner.
  $evm = MiqAeMethodService::MiqAeService.new(MiqAeEngine::MiqAeWorkspaceRuntime.new)

  # Method for logging
  def log(level, message)
    @method = 'load_tags'
    $evm.log(level, "#{@method} - #{message}")
  end

  def tag_obj (obj, category_name, tag_name, obj_type)
    attempt = 1
    until obj.tagged_with?(category_name,tag_name) || attempt > 5
      obj.tag_assign("#{category_name}/#{tag_name}")
      log(:info, "Tagged: #{obj.name} with Cat: #{category_name} and Tag: #{tag_name}")
      attempt += 1
    end
    if obj.tagged_with?(category_name,tag_name)
      log(:info, "Confirmed: #{obj_type.upcase} #{obj.name} is tagged Cat: #{category_name} and Tag: #{tag_name}")
    else
      log(:info, "FAILED: #{obj_type.upcase} #{obj.name} is not tagged Cat: #{category_name} and Tag: #{tag_name}")
    end
  end

  def openFile(filename)
    return File.open(filename, 'r')
  end

  def closeFile(file)
    file.close
  end

  def assign_obj_tags(obj, tags, obj_type)
    unless tags.nil? || tags.empty?
      tagsArray = tags.split(',')

      tagsArray.each do |tag|
        category, tag_value = tag.split('/')
        log(:info, "Assign: #{obj_type.upcase} #{obj.name} Cat: #{category} and Tag: #{tag_value}")
        tag_obj(obj, category, tag_value, obj_type)
      end
    end
  end

  def loader(obj_type)
    search = obj_type
    search = 'vm_or_template' if obj_type == 'vm'
    
    file = "/var/www/miq/vmdb/tmp/tag_#{obj_type}.data"
    log(:info, "Loading #{search} tags from #{file}")

    # Open file
    src_file = openFile(file)

    src_file.each do | aLine |

      aLineArray = aLine.chomp.split('|')

      obj_name = aLineArray[0].split('=')[1]
      obj_tags = aLineArray[1].split('=')[1]

      obj = $evm.vmdb(search).find_by_name(obj_name)

      unless obj.nil?
	assign_obj_tags(obj, obj_tags, obj_type)
      else
	log(:info, "#{search} to tag <#{obj_name}> not found (nil).")
      end
    end
    # Close file
    closeFile(src_file)
  end

  log(:info, "Method Started")

  ARGV.each do |i|
    loader(i)
  end

  log(:info, "Method Ended")
  exit

rescue => err
  log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit
end

