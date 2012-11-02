#
# Cookbook Name:: replication_for_dr
# Recipe:: master_configuration
#

if node[:engineyard][:environment][:db_stack_name] =~ /postgres9(.*)/
  postgres_root    = '/db/postgresql'
  postgres_version = "#{node['postgresql']['short_version']}"

  execute "update-pg-hba-conf" do
    command "echo 'host    replication     postgres        127.0.0.1/32              md5' >> #{postgres_root}/#{postgres_version}/data/pg_hba.conf"
    not_if "grep 'host    replication     postgres        127.0.0.1/32              md5' #{postgres_root}/#{postgres_version}/data/pg_hba.conf"
  end

  execute "update-custom-pg-hba-conf" do
    command "echo 'host    replication     postgres        127.0.0.1/32              md5' >> #{postgres_root}/#{postgres_version}/custom_pg_hba.conf"
    not_if "grep 'host    replication     postgres        127.0.0.1/32              md5' #{postgres_root}/#{postgres_version}/custom_pg_hba.conf"
  end
  
  execute "reload-postgres-config" do
    command "su - postgres -c 'pg_ctl reload -D #{postgres_root}/#{postgres_version}/data/'"
  end
end