#
# Cookbook Name:: db_failover
# Recipe:: default
#

if ["db_master"].include?(node[:instance_role])

  case node[:engineyard][:environment][:db_stack_name]
  when /mysql(.*)/
    include_recipe "db_failover::mysql_failover"
  when /postgres9(.*)/
    include_recipe "db_failover::postgresql_failover"
  end
        
end
