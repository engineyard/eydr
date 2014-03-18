#
# Cookbook Name:: replication_for_dr
# Recipe:: default
#

if ["db_master", "solo"].include?(node[:instance_role])

  case node[:engineyard][:environment][:db_stack_name]
  when /mysql(.*)/
    Chef::Log.info "Configuring replication for MySQL"
    include_recipe "replication_for_dr::mysql_replication"  
  when /postgres9(.*)/
    Chef::Log.info "Configuring replication for PostgreSQL"
    include_recipe "replication_for_dr::postgresql_replication"
  end
        
end
