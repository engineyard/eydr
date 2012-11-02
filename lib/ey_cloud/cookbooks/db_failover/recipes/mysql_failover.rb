#
# Cookbook Name:: db_failover
# Recipe:: mysql_failover
#

if ["db_master"].include?(node[:instance_role])
  execute "remove-replication-configuration" do
    command "rm /db/mysql/master.info"
    only_if { File.exists?("/db/mysql/master.info") }
  end
  
  execute "remove-replication-configuration" do
    command "rm /etc/mysql.d/replication.cnf"
    only_if { File.exists?("/etc/mysql.d/replication.cnf") }
  end  

  execute "remote-replication-relay-files" do
    command "rm /db/mysql/*relay*"
    only_if { File.exists?("/db/mysql/relay-log.info") }
  end

  case node[:engineyard][:environment][:db_stack_name]
  when "mysql5_0","mysql5_1"
    ruby_block "promote-5.0-5.1-slave-to-master" do
      block do
        `mysql -u root -p #{node[:owner_pass]} -e 'stop slave;'`
        `mysql -u root -p #{node[:owner_pass]} -e 'CHANGE master TO master_host='';'`
        `mysql -u root -p #{node[:owner_pass]} -e 'SET global read_only = 0;'`
        `mysql -u root -p #{node[:owner_pass]} -e 'flush privileges;'`
        `/etc/init.d/mysql restart`
      end
    end
  when "mysql5_15"
    ruby_block "promote-5.5-slave-to-master" do
      block do
        `mysql -u root -p #{node[:owner_pass]} -e 'stop slave;'`
        `mysql -u root -p #{node[:owner_pass]} -e 'reset slave all;'`
        `mysql -u root -p #{node[:owner_pass]} -e 'SET global read_only = 0;'`
        `mysql -u root -p #{node[:owner_pass]} -e 'flush privileges;'`
        `/etc/init.d/mysql restart`
      end
    end
  end    
end
