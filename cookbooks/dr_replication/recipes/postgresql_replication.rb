#
# Cookbook Name:: replication_for_dr
# Recipe:: postgresql_replication
#

postgres_root    = '/db/postgresql'
postgres_version = "#{node['postgresql']['short_version']}"

template "#{postgres_root}/#{postgres_version}/data/recovery.conf" do
  source "recovery.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
  backup 0
  variables(
    :standby_mode => "on",
    :primary_host => "127.0.0.1",
    :primary_port => 5433,
    :primary_user => "postgres",
    :primary_password => node[:owner_pass],
    :trigger_file => "/tmp/postgresql.trigger"
  )
end

execute "make-wal-directory" do
  command "mkdir -p #{postgres_root}/#{postgres_version}/wal/"
  not_if { File.exists?('#{postgres_root}/#{postgres_version}/wal/') }
end

Chef::Log.info "Master Host: #{node[:replication][:master][:public_hostname]}"
template "/engineyard/bin/setup_replication.sh" do
  source "setup_postgres_replication.sh.erb"
  owner "root"
  group "root"
  mode 0755
  backup 0
  variables(
    :master => node[:replication][:master][:public_hostname],
    :slave => node[:replication][:slave][:public_hostname],
    :version => postgres_version
  )
end

execute "setup-replication" do
  command "/engineyard/bin/setup_replication.sh"
end
