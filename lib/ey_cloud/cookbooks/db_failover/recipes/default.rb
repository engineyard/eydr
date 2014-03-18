#
# Cookbook Name:: db_failover
# Recipe:: default
#

if ["db_master", "solo"].include?(node[:instance_role]) && node[:dr_environment_name] == node[:engineyard][:environment][:name]

  if node[:db_failover]
    case node[:engineyard][:environment][:db_stack_name]
    when /mysql(.*)/
      include_recipe "db_failover::mysql_failover"
    when /postgres9(.*)/
      include_recipe "db_failover::postgresql_failover"
    end
  end

  include_recipe "db_failover::monitoring"
        
end
