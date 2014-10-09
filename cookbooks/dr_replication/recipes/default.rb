#
# Cookbook Name:: replication_for_dr
# Recipe:: default
#

if (db_master? || solo?) && (node[:ec2][:public_hostname] == node[:dr_replication][:master][:public_hostname])
  Chef::Log.info "Configuring master for mysql replication"
  include_recipe "dr_replication::keys"
  include_recipe "dr_replication::master_configuration"
end

if (db_master? || solo?) && (node[:ec2][:public_hostname] == node[:dr_replication][:slave][:public_hostname])
  include_recipe "dr_replication::keys"
  include_recipe "ssh_tunnel"
  include_recipe "dr_replication::#{node['engineyard']['environment']['db_stack_name'].split(/[1..9]/).first}_replication"
  include_recipe "dr_replication::#{node['engineyard']['environment']['db_stack_name'].split(/[1..9]/).first}_monitoring"
end
