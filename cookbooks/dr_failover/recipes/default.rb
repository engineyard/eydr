#
# Cookbook Name:: db_failover
# Recipe:: default
#

if (db_master? || solo?) && (node[:ec2][:public_hostname] == node[:replication][:slave][:public_hostname])

  if node[:failover]
    case node[:engineyard][:environment][:db_stack_name]
    when /mysql(.*)/
      include_recipe "db_failover::mysql_failover"
    when /postgres9(.*)/
      include_recipe "db_failover::postgresql_failover"
    end
  end

  include_recipe "db_failover::monitoring"

end
