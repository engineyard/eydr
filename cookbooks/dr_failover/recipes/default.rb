#
# Cookbook Name:: dr_failover
# Recipe:: default
#

if node[:failover] && node[:ec2][:public_hostname] == node[:dr_replication][:slave][:public_hostname]
  if db_master? || solo?
    include_recipe "dr_failover::#{node['engineyard']['environment']['db_stack_name'].split(/[1..9]/).first}_failover"
  end

  if node[:dns_failover][:enabled] && app_master?
    include_recipe "dr_failover::dns_failover"
  end
end
