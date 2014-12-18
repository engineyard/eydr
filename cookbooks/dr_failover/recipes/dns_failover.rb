#
# Cookbook Name:: dns_failover
# Recipe:: default
#

include_recipe "dr_failover::#{node[:dns_failover][:provider]}" 
