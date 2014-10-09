#
# Cookbook Name:: replication_for_dr
# Recipe:: mysql_replication
#

# Set datadir and logbase depending on MySQL version
case node[:mysql][:version]
when "5.0.51"
  datadir="/db/mysql"
  logbase="/db/mysql/log/"
else
  datadir="/db/mysql/#{node['mysql']['short_version']}/data"
  logbase="/db/mysql/#{node['mysql']['short_version']}/log/"
end

file "/home/deploy/id_rsa" do
  source "id_rsa.pub"
  owner node[:owner_name]
  group node[:owner_name]
  mode 0600
end

bash "authorize-keys" do
  code "cat /home/#{node[:owner_name]}/id_rsa.pub >> /home/#{node[:owner_name]}/.ssh/extra_authorized_keys"
  not_if 'grep "`cat /home/deploy/id_rsa.pub`" /home/deploy/.ssh/extra_authorized_keys'
  only_if { File.exists?("/home/#{node[:owner_name]}/id_rsa.pub") }
end

# Download xtrabackup from URL specificed in attributes
bash "download-xtrabackup" do
  user node['owner_name']
  cwd "/home/#{node['owner_name']}/"
  code "wget #{node[:dr_replication][:xtrabackup_download_url]}"
  not_if { File.exists? "/home/#{node['owner_name']}/#{node[:dr_replication][:xtrabackup_download_url].split("/").last}"}
end

# Untar xtrabackup
bash "untar-xtrabackup" do
  user node['owner_name']
  cwd "/home/#{node['owner_name']}/"
  code "tar zxvf #{node[:dr_replication][:xtrabackup_download_url].split("/").last}"
end

# Copy xtrabackup into /usr/bin so that it's in the PATH
bash "copy-xtrabackup" do
  user "root"
  code "cp /home/#{node['owner_name']}/#{node[:dr_replication][:xtrabackup_download_url].split("/").last.split("-")[0..2].join("-")}*/bin/* /usr/bin/"
end

# Ensure proper ownership
bash "chown-xtrabackup" do
  user "root"
  cwd "/usr/bin/"
  code "chown #{node['owner_name']}:#{node['owner_name']} innobackupex xbcrypt xbstream xtrabackup*"
end

# Install libaio (required for xtrabackup)
package "dev-libs/libaio" do
  action :install
end

# Download qpress from the URL specified in attributes (used for compression)
bash "download-qpress" do
  user node['owner_name']
  cwd "/home/#{node['owner_name']}/"
  code "wget #{node[:dr_replication][:qpress_download_url]}"
  not_if { File.exists? "/home/#{node['owner_name']}/#{node[:dr_replication][:qpress_download_url].split("/").last}"}
end

# Untar qpress
bash "copy-qpress" do
  user node['owner_name']
  cwd "/home/#{node['owner_name']}/"
  code "tar xvf #{node[:dr_replication][:qpress_download_url].split("/").last}"
end

# Copy apress into /usr/bin so that it's in the PATH
bash "copy-qpress" do
  user "root"
  code "cp /home/#{node['owner_name']}/qpress /usr/bin/"
end

# Drop slave replication settings in place
template "/etc/mysql.d/replication.cnf" do
  source "replication.cnf.erb"
  variables({
    :server_id => node[:engineyard][:this].split("-")[1].to_i(16),
    :datadir => datadir
  })
end

# Render the script that sets up replication
template "/engineyard/bin/setup_replication.sh" do
  source "setup_mysql_replication.sh.erb"
  owner "root"
  group "root"
  mode 0755
  backup 0
  variables({
    :master_pass => node[:owner_pass],
    :initiate_hostname => node[:dr_replication][:initiate][:public_hostname],
    :slave_public_hostname => node[:dr_replication][:slave][:public_hostname],
    :datadir => datadir,
    :user => node[:owner_name],
    :db_name => node[:engineyard][:environment][:apps].first[:database_name],
    :db_pass => node[:owner_pass],
    :db_user => node[:owner_name]
  })
end

# Only run the setup replication script if the enable_replication flag is set to true in the attributes
if node[:establish_replication]
  bash "setup-replication" do
    code "/engineyard/bin/setup_replication.sh > /home/#{node['owner_name']}/setup_replication.log 2>&1"
  end

  # Add monitoring if configuring replication
  execute "add-mysql-replication-monitoring" do
    command 'sed -i \'s|Exec "mysql" "/engineyard/bin/check_mysql.sh" "connections"|Exec "mysql" "/engineyard/bin/check_mysql.sh" "connections"\n      Exec "mysql" "/engineyard/bin/check_mysql.sh" "replication" "8000" "40000"|g\' /etc/engineyard/collectd.conf'
    action :run
    not_if "grep 'replication' /etc/engineyard/collectd.conf"
    only_if "test -f /etc/engineyard/collectd.conf"
  end
end
