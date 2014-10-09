#
# Cookbook Name:: dr_replication
# Recipe:: keys
#

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

ssh_keys = [keys["public_key"]]

["extra_authorized_keys", "authorized_keys"].each do |key|
  # Loading existing keys
  if File.exists?("/home/#{node[:owner_name]}/.ssh/#{key}")
    File.open("/home/#{node[:owner_name]}/.ssh/#{key}").each do |line|
      if line.start_with?("ssh")
        ssh_keys += Array(line.delete "\n")
      end
    end
  end

  ssh_keys.uniq!

  template "/home/#{node[:owner_name]}/.ssh/#{key}" do
    source "authorized_keys.erb"
    owner node[:owner_name]
    group node[:owner_name]
    mode 0600
    variables :ssh_keys => ssh_keys
  end
end

if node[:engineyard][:environment][:db_stack_name] =~ /postgres9(.*)/

  directory "/var/lib/postgresql/.ssh/" do
    owner "postgres"
    group "postgres"
    mode "0755"
    recursive true
    action :create
  end

  execute "touch-postgresql-authorized-keys" do
    command "touch /var/lib/postgresql/.ssh/authorized_keys"
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
