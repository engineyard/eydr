require 'yaml'
require 'erb'
require 'fog'

class Setup
  def initialize(options)
  	config = YAML.load_file(options[:config])
    config["dr"].each { |key, value| instance_variable_set("@#{key}", value) }
    @account_str = options[:account].eql?("") ? "" : " --account #{options[:account]}"
  end

  def setup
    mount_volume if @db_type.eql?("mysql")
    download_cookbooks
    modify_cookbooks
    apply_cookbooks
    verify_replication
  end
  
  def mount_volume
    connection_slave = Fog::Compute.new(
      :provider                 => 'AWS',
      :aws_secret_access_key    => @aws_secret_access_key,
      :aws_access_key_id        => @aws_access_key_id,
      :region                   => @slave_region
    )

    connection_master = Fog::Compute.new(
      :provider                 => 'AWS',
      :aws_secret_access_key    => @aws_secret_access_key,
      :aws_access_key_id        => @aws_access_key_id,
      :region                   => @master_region
    )

    db_slave = connection_slave.servers.all('instance-id' => @db_slave_id).first
    db_master = connection_master.servers.all('instance-id' => @db_master_id).first
    
    #snapshot_id = connection_slave.copy_snapshot(db_master.volumes.find {|x| x.device =~ /\/dev\/sdz2/}.snapshots.last.id, @master_region).body["snapshotId"]
    snapshot_id = 'snap-f54ef4cc'
    sleep 5 while connection_slave.snapshots.get(snapshot_id).state != "completed"
    
    vol = db_slave.volumes.create(:snapshot_id => snapshot_id, :device => "/dev/sdj3", :availability_zone => db_slave.availability_zone)
    sleep 5 while connection_slave.describe_volumes("volume-id" => vol.id).body["volumeSet"].first["attachmentSet"].first["status"] != "attached"
  end

  def download_cookbooks
    # Download recipes and exit in the event of a failure
    Dir.chdir workspace_path
    `rm -rf #{workspace_path}/*`
    `ey recipes download --environment #{@master_environment_name} #{@account_str}`
    if $?.exitstatus == 1
      puts "Recipes could not be downloaded from #{@master_environment_name}."
      puts "Try specifying an account with --account [account name]" if @account_str.eql? ""
      Process.exit!
    end
  end
  
  def modify_cookbooks    
    # Copy in custom recipes required for replication and failover
    copy_cookbook("/cookbooks/replication_for_dr")
    copy_cookbook("/cookbooks/ssh_key_connection")
    copy_cookbook("/cookbooks/db_failover")

    # Read and backup main recipes
    main_recipe = File.join("#{workspace_path}/cookbooks/","/main/recipes/default.rb")  
    FileUtils.cp_r(main_recipe, "#{workspace_path}/cookbooks/main_default.rb.bak")     

    # Add replication recipes to main Chef recipes
    contents = File.read(main_recipe)
    contents += <<-DOC
include_recipe "ssh_key_connection"

if node[:ec2][:public_hostname] == "#{@master_public_hostname}"
  include_recipe "replication_for_dr::master_configuration"
end

if node[:ec2][:public_hostname] == "#{@slave_public_hostname}"
  node[:master_host] = "#{@master_public_hostname}"
  node[:master_pass] = "#{@master_pass}"
  include_recipe "ssh_tunnel"        
  include_recipe "replication_for_dr"   
end
    DOC
    File.open(main_recipe,"w") do |file|
      file.write(contents)
    end

    # Write out SSH tunnel default recipe with appropriate hostname and copy into cookbooks
    template = ERB.new(File.read(File.join(current_path,"/templates/default.rb.erb")))
    ssh_hostname = @master_public_hostname
    defaultrb = template.result(binding)
    File.open(File.join(current_path, "/cookbooks/ssh_tunnel/recipes/default.rb"),"w") do |file|
      file.write(defaultrb)
    end 
    copy_cookbook("/cookbooks/ssh_tunnel")

    # Generate a new SSH key for the SSH tunnel
    puts "Hit enter to set a passphrase on the SSH key for the tunnel"
    `ssh-keygen -t dsa -b 1024 -f #{current_path}/cookbooks/ssh_key_connection/files/default/tunnel -N '' -C 'SSH Tunnel Key'`
  end

  def apply_cookbooks
    # Run Chef with replication cookbooks added
    puts "Running updated Chef recipes to configure replication"
    puts ""
    `ey recipes upload --apply --environment #{@slave_environment_name} #{@account_str}`    
    `ey recipes upload --apply --environment #{@master_environment_name} #{@account_str}`
    puts "When the dasboard shows the Chef run as complete, hit enter to continue"
    STDIN.gets
    
    check_position

    # Copy original main recipe back into place and remove backup
    FileUtils.cp_r("#{workspace_path}/cookbooks/main_default.rb.bak", "#{workspace_path}/cookbooks/main/recipes/default.rb")
    `rm #{workspace_path}/cookbooks/main_default.rb.bak`

    # Upload Chef recipes with replication cookbooks added by disabled
    `ey recipes upload --environment #{@master_environment_name} #{@account_str}`
    `ey recipes upload --environment #{@slave_environment_name} #{@account_str}`     
  end
  
  def check_position
    if @db_type.eql?("mysql")
      puts "Seconds behind master should be 0 if replication is caught up\n"
      continue = "y"
      while continue == "y"
        puts `ssh deploy@#{@slave_public_hostname} "mysql -uroot -p#{@master_pass} -e 'show slave status\\G' | grep Seconds_Behind_Master"`.strip
        puts ""
        puts "Would you like to check this information again?"
        continue = STDIN.gets.chomp!
      end
    else
      # Output information to check on replication status
      puts "The following positions will match if replication is caught up\n"
      continue = "y"
      while continue == "y"
        receiver = `ssh deploy@#{@slave_public_hostname} "ps -efa | pgrep -fl receiver | head -1" |  awk '{print $7}'`
        sender = `ssh deploy@#{@master_public_hostname} "ps -efa | pgrep -fl sender | head -1" |  awk '{print $9}'`
        puts "Master: #{sender}"
        puts "Slave:  #{receiver}"
        puts ""
        puts "Would you like to check this information again?"
        continue = STDIN.gets.chomp!
      end
    end
  end    
  
  def verify_replication
    # Success information
    success = false
    if @db_type.eql?("mysql")      
      status = `ssh deploy@#{@slave_public_hostname} "mysql -u root -p#{@master_pass} -e 'show slave status\\G' | grep Seconds_Behind_Master"`
      success = true if status.include? 'Seconds_Behind_Master'
    else
      status = `ssh deploy@#{@slave_public_hostname} 'ps -efa | pgrep -fl receiver | head -1' |  awk '{print $4}'`
      success = true if status.include? 'receiver'
    end
    if success
      puts "Replication has been configured."
      puts "Please run 'ey recipes download -e #{@master_environment_name}#{@account_str}' to get the latest cookbooks."
      puts "Add the following line in your main recipes to trigger a failover:  'require_recipe 'db_failover'"
    else
      puts "Replication did not configure properly."
      puts "Please check the Chef and PostgreSQL logs to troubleshoot."
      puts ""
      puts "Chef logs: /var/log/chef.custom.*.log"
      puts "PostgreSQL logs: /db/postgresql/9.1/data/pg_log/postgresql.*.csv"
      puts "MySQL logs: /db/mysql/<version>/log"      
    end
    puts ""
  end    
  
  def current_path
    @path ||= File.dirname(File.expand_path(__FILE__))
  end
  
  def workspace_path
    "#{current_path}/workspace/"
  end
  
  def copy_cookbook(path)
    FileUtils.cp_r(File.join(current_path, path), "#{workspace_path}/cookbooks/")
  end   

end
