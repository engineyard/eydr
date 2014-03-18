#
# Cookbook Name:: replication_for_dr
# Recipe:: master_configuration
#

case node[:engineyard][:environment][:db_stack_name]
when /mysql(.*)/
  if ["solo"].include?(node[:instance_role])
    remote_file "/etc/mysql.d/logbin.cnf" do
      source "logbin.cnf"
      owner "root"
      group "root"
      mode 0600
      backup 0
    end

    execute "restart-mysql" do
      command "/etc/init.d/mysql restart"
    end
  end

when /postgres9(.*)/
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
