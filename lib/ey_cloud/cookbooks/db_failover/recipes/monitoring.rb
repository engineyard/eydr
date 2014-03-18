#
# Cookbook Name:: db_failover
# Recipe:: monitoring
#

case node[:engineyard][:environment][:db_stack_name]
when /mysql(.*)/
  execute "add-mysql-replication-monitoring" do
    command 'sed -i \'s|Exec "mysql" "/engineyard/bin/check_mysql.sh" "connections"|Exec "mysql" "/engineyard/bin/check_mysql.sh" "connections"\n      Exec "mysql" "/engineyard/bin/check_mysql.sh" "replication" "8000" "40000"|g\' /etc/engineyard/collectd.conf'
    action :run
    not_if "grep 'replication' /etc/engineyard/collectd.conf"
    only_if "test -f /etc/engineyard/collectd.conf"
  end
end
