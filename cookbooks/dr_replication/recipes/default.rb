#
# Cookbook Name:: dr_replication
# Recipe:: default
#

if (db_master? || solo?) && (node[:ec2][:public_hostname] == node[:dr_replication][:master][:public_hostname])
  Chef::Log.info "Configuring master for replication"
  include_recipe "dr_replication::keys"
  include_recipe "dr_replication::#{node['engineyard']['environment']['db_stack_name'].split(/[0-9]/).first}_master_configuration"
end

if (db_master? || solo?) && (node[:ec2][:public_hostname] == node[:dr_replication][:slave][:public_hostname])
  Chef::Log.info "Configuring slave for replication"
  include_recipe "dr_replication::keys"
  include_recipe "ssh_tunnel"
  include_recipe "dr_replication::#{node['engineyard']['environment']['db_stack_name'].split(/[0-9]/).first}_replication"

  if node[:establish_replication]
    Chef::Log.info "Failed over"
    include_recipe "dr_replication::#{node['engineyard']['environment']['db_stack_name'].split(/[0-9]/).first}_monitoring"
  end
end
