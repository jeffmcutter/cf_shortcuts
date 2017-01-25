###################################
# Bulk apply tags based on specified CSV input file.
# Modify get_hostname_to_container to address non-consistent hostname to container name situations.
#
# jcutter@redhat.com
###################################

begin

  require 'optparse'

  @debug = true

  # For use via rails runner.
  $evm = MiqAeMethodService::MiqAeService.new(MiqAeEngine::MiqAeWorkspaceRuntime.new)

  def get_hostname_to_container
    htoc = {}
    $evm.vmdb('vm').all.each do |vm|
      # Get hostname from SmartState collected /etc/hostname file.
      #hostname = vm.files.select {|i| i.name == '/etc/hostname'}.first.contents.chomp rescue nil
      # Get hostname from tools collected hostname.
      hostname = vm.hardware.hostnames.first rescue nil
      hostname = vm.name if hostname.blank?
      htoc[hostname] = vm.name
    end
    htoc
  end

  def tag_obj (obj, category_name, tag_name, obj_type)
    attempt = 1
    until obj.tagged_with?(category_name,tag_name) || attempt > 5
      obj.tag_assign("#{category_name}/#{tag_name}")
      puts "Tagged: #{obj.name} with Cat: #{category_name} and Tag: #{tag_name}"
      attempt += 1
    end
    if obj.tagged_with?(category_name,tag_name)
      puts "Confirmed: #{obj_type.upcase} #{obj.name} is tagged Cat: #{category_name} and Tag: #{tag_name}"
    else
      puts "FAILED: #{obj_type.upcase} #{obj.name} is not tagged Cat: #{category_name} and Tag: #{tag_name}"
    end
  end

  def assign_obj_tag(obj, obj_type, category, tag_value)
    puts "Assign: #{obj_type.upcase} #{obj.name} Cat: #{category} and Tag: #{tag_value}"
    tag_obj(obj, category, tag_value, obj_type)
  end

  def tagger(filename)

    # Open file
    src_file = File.open(filename, 'r')

    src_file.each do | line |

      next if line =~ /^#/ || line =~ /^\s+$/
      lineArray = line.chomp.split(',')

      obj_name = lineArray[0]
      obj_type = lineArray[1]
      obj_type = 'vm_or_template' if obj_type == 'vm'
      category = lineArray[2]
      tag_value = lineArray[3]

      if obj_type == 'vm_or_template'
        obj = $evm.vmdb(obj_type).find_by_name(@htoc[obj_name]) # Get the container name from the hostname to container name hash.
      else
        obj = $evm.vmdb(obj_type).find_by_name(obj_name)
      end

      unless obj.nil?
	      assign_obj_tag(obj, obj_type, category, tag_value)
      else
	      puts "#{obj_type} to tag <#{obj_name}> not found (nil)."
      end
    end

    # Close file
    src_file.close
  end

  options = {}
  opts = OptionParser.new
  opts.banner = "Usage: bulk_tag.rb [options]"
  opts.on("-f", "--file FILE", String, "Specify input file") do |f|
    options[:file] = f
  end
  opts.parse!
  if options[:file].nil?
    puts opts.help
    exit 1
  end

  @htoc = get_hostname_to_container
  tagger(options[:file])

  exit

rescue => err
  puts err
  exit 1
end

