#
# Cookbook Name:: dns_failover
# Recipe:: default
#

if ["app_master"].include?(node[:instance_role])
  include_recipe "dns_failover::#{node[:dns_failover][:provider]}"
end
