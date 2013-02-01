#
# Cookbook Name:: replication_for_dr
# Recipe:: mysql_replication
#

directory "/db2/" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

execute "mount-volume" do
  command "mount -t ext3 /dev/xvdj3 /db2"
  not_if { `df -h | grep xvdj3` }
end

case node[:mysql][:version]
when "5.0.51"
  datadir="/db/mysql"
  logbase="/db/mysql/log/"
else
  datadir="/db/mysql/#{node['mysql']['short_version']}/data"
  logbase="/db/mysql/#{node['mysql']['short_version']}/log/"
end

template "/etc/mysql.d/replication.cnf" do
  source "replication.cnf.erb"
  variables({
    :server_id => node[:engineyard][:this].split("-")[1].to_i(16),
    :datadir => datadir
  })
end

template "/root/.mytop" do
  source "dotmytop.erb"
  variables({
    :master_pass => node[:master_pass]
  })
end

ruby_block 'read-master-status' do
  block do
    file_contents = File.read("/db/mysql/.snapshot_backup_master_status.txt")
    node[:master_log_file] = file_contents.match(/File:(.*)\n/)[1].strip
    node[:master_log_pos] = file_contents.match(/Position:(.*)\n/)[1].strip
    Chef::Log.info("using master_log_file: " + node[:master_log_file].inspect)
    Chef::Log.info("using master_log_pos: " + node[:master_log_pos].inspect)
  end
end


template "/engineyard/bin/setup_replication.sh" do
  source "setup_mysql_replication.sh.erb"
  owner "root"
  group "root"
  mode 0755
  backup 0
  variables(
    :master_pass => node[:master_pass],
    :master_log_file => node[:master_log_file],
    :master_log_pos => node[:master_log_pos]
  )
end

execute "setup-replication" do
  command "/engineyard/bin/setup_replication.sh"
end
