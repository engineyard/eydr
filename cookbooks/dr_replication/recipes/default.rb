#
# Cookbook Name:: replication_for_dr
# Recipe:: default
#

if (db_master? || solo?) && (node[:ec2][:public_hostname] == node[:replication][:master][:public_hostname])
  Chef::Log.info "Configuring master for mysql replication"
  include_recipe "dr_replication::dr_keys"
  include_recipe "dr_replication::master_configuration"
end

if (db_master? || solo?) && (node[:ec2][:public_hostname] == node[:replication][:slave][:public_hostname])
  include_recipe "dr_replication::dr_keys"
  include_recipe "ssh_tunnel"
  case node[:engineyard][:environment][:db_stack_name]
  when /mysql(.*)/
    Chef::Log.info "Configuring replication for mysql"
    include_recipe "dr_replication::mysql_replication"
  when /postgres9(.*)/
    Chef::Log.info "Configuring replication for postgresql"
    include_recipe "dr_replication::postgresql_replication"
  end
end
