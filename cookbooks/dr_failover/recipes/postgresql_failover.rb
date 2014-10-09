#
# Cookbook Name:: db_failover
# Recipe:: postgresql_failover
#

ruby_block "promote-slave-to-master" do
  block do
    `touch /tmp/postgresql.trigger`
  end
end
