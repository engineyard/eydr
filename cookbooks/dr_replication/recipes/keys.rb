#
# Cookbook Name:: dr_replication
# Recipe:: keys
#

begin
  keys = Chef::EncryptedDataBagItem.load("dr_keys", node[:environment][:framework_env])

  file "/root/.ssh/id_rsa" do
    owner node[:owner_name]
    group node[:owner_name]
    mode 0600
    action :create
    content keys[:private_key]
  end

  file "/root/.ssh/id_rsa.pub" do
    owner node[:owner_name]
    group node[:owner_name]
    mode 0600
    action :create
    content keys[:public_key]
  end
rescue
  Chef::Log.info "Encryption key not found"
end
