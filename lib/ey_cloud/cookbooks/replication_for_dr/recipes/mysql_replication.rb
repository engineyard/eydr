#
# Cookbook Name:: replication_for_dr
# Recipe:: mysql_replication
#

directory "/db2" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

mount "/db2" do
  fstype "ext3"
  device "/dev/#{node[:replication_mount]}"
  action :mount
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

template "/engineyard/bin/setup_replication.sh" do
  source "setup_mysql_replication.sh.erb"
  owner "root"
  group "root"
  mode 0755
  backup 0
  variables({
    :master_pass => node[:master_pass]
  })
end

execute "setup-replication" do
  command "/engineyard/bin/setup_replication.sh"
  not_if "mysql -uroot -p#{node[:master_pass]} -e\"show slave status\G\" | grep 'Seconds_Behind_Master: 0'"
end

execute "umount-db2" do
  command "umount /db2"
  only_if "cat /proc/mounts | grep db2"  
end
