#
# Cookbook Name:: dr_replication
# Recipe:: keys
#

if[:dr_repication][:use_metadata_key]
  encrypted_data_bag_secret = metadata_any_get_with_default("encrypted_data_bag_secret", "<ADD TO METADATA>")

  file "/etc/chef/encrypted_data_bag_secret" do
    owner node[:owner_name]
    group node[:owner_name]
    mode 0600
    action :nothing
    content encrypted_data_bag_secret
  end.run_action(:create);
end

keys = Chef::EncryptedDataBagItem.load("dr_keys", node[:environment][:framework_env])

file "/home/#{node[:owner_name]}/.ssh/id_rsa" do
  owner node[:owner_name]
  group node[:owner_name]
  mode 0600
  action :create
  content keys["private_key"]
end

file "/home/#{node[:owner_name]}/.ssh/id_rsa.pub" do
  owner node[:owner_name]
  group node[:owner_name]
  mode 0600
  action :create
  content keys["public_key"]
end

if node[:engineyard][:environment][:db_stack_name] == /postgres/

  directory "/var/lib/postgresql/.ssh/" do
    owner "postgres"
    group "postgres"
    mode "0755"
    recursive true
    action :create
  end

  bash "touch-postgresql-authorized-keys" do
    code "touch /var/lib/postgresql/.ssh/authorized_keys"
    not_if { File.exists?('/var/lib/postgresql/.ssh/authorized_keys') }
  end

  file "/var/lib/postgresql/.ssh/id_rsa" do
    owner "postgres"
    group "postgres"
    mode 0700
    backup 0
    content keys["private_key"]
  end

  file "/var/lib/postgresql/.ssh/id_rsa.pub" do
    owner "postgres"
    group "postgres"
    mode 0700
    backup 0
    content keys["public_key"]
  end

  bash "configure-authorized-keys-for-postgres"  do
    code "cat /var/lib/postgresql/.ssh/id_rsa.pub >> /var/lib/postgresql/.ssh/authorized_keys"
    not_if 'grep "`cat /var/lib/postgresql/.ssh/id_rsa.pub`" /var/lib/postgresql/.ssh/authorized_keys'
  end
end
