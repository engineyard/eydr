
["tunnel","tunnel.pub"].each do |file|
  remote_file "/root/.ssh/#{file}" do
    source file
    owner "root"
    group "root"
    mode 0600
    backup 0
  end
end

execute "configure-authorized-keys-for-tunnel"  do
  command "cat /root/.ssh/tunnel.pub >> /root/.ssh/authorized_keys"
  not_if 'grep "`cat /root/.ssh/tunnel.pub`" /root/.ssh/authorized_keys'
end

if node[:engineyard][:environment][:db_stack_name] =~ /postgres9(.*)/
  
  directory "/var/lib/postgresql/.ssh/" do
    owner "postgres"
    group "postgres"
    mode "0755"
    recursive true
    action :create
  end  
  
  execute "touch-postgresql-authorized-keys" do
    command "touch /var/lib/postgresql/.ssh/authorized_keys"
    not_if { File.exists?('/var/lib/postgresql/.ssh/authorized_keys') }
  end  
  
  remote_file "/var/lib/postgresql/.ssh/id_dsa" do
    source "tunnel"
    owner "postgres"
    group "postgres"
    mode 0700
    backup 0
  end

  remote_file "/var/lib/postgresql/.ssh/id_dsa.pub" do
    source "tunnel.pub"
    owner "postgres"
    group "postgres"
    mode 0700
    backup 0
  end
  
  execute "configure-authorized-keys-for-postgres"  do
    command "cat /var/lib/postgresql/.ssh/id_dsa.pub >> /var/lib/postgresql/.ssh/authorized_keys"
    not_if 'grep "`cat /var/lib/postgresql/.ssh/id_dsa.pub`" /var/lib/postgresql/.ssh/authorized_keys'
  end  
end