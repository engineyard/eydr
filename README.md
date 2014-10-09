EY Cloud Disaster Recovery
==========================

Pre-Requisites
--------------
1. Add yourself as collaborator to the account.
2. Ensure the following gems are installed locally:

* chef (10.16.4)
* knife-solo_data_bag (1.1.0)

3. Create an secret key to be used to encrypt data bags:

```
openssl rand -base64 512 > ~/.chef/encrypted_data_bag_secret
```

4. Create a key to be used for the SSH tunnel and other SSH connections between the database instances:

```
ssh-keygen -t rsa -b 2048 -f ./id_rsa
```

5. Add the SSH key generated in step 4 to the dashboard.

6. Ensure a knife.rb file is configured on local machine:

```
node_name           “solo”
data_bag_path       "<cookbook_path>/data_bags"
```

7. Create a json file containing a public and private key to be used by the SSH tunnel (see dr_keys.json.example).
8. Create an encrypted data bag containing the ssh keys:

```
EDITOR=vi knife solo data bag create dr_keys <FRAMEWORK_ENV> --json-file <framework_env>.json --secret-file ~/.chef/encrypted_data_bag_secret
```

9. Update the slave environment database password to match the master environment database password.  This must be done via the awsm console and can not be done by customers. (DOC-2184)

Boot and Configure
------------------
1. In another region, configure an environment identical to the live environment and boot instances.
2. Configure the following attributes in the dr_replication cookbook:

```
default[:dr_replication] = {
  :master => {
    :public_hostname => "" # The public hostname of the master database
  },
  :initiate => {
    :public_hostname => "" # The public hostname of the database you want to rsync the data from (can be db_slave)
  },
  :slave => {
    :public_hostname => "" # The public hostname of the slave database
  }

default[:establish_replication] = true # Set to true to establish replication when Chef runs
default[:failover] = false # Set to true to failover to slave environment when Chef runs
```

3. Upload the encrypted data bag key to all instances to /etc/chef/

```
for server in `ey servers -Su -e <env> --account=JobMatcher` ; do scp -o StrictHostKeyChecking=no ~/.chef/encrypted_data_bag_secret $server:/home/deploy/; ssh -o StrictHostKeyChecking=no $server 'sudo mv /home/deploy/encrypted_data_bag_secret /etc/chef/';  done
```

4. Upload and apply Chef cookbooks:

```
ey recipes upload --apply -e <master_environment_name>
ey recipes upload --apply -e <slave_environment_name>
```

Steps to Failover
-----------------
1. Set the failover attribute to true and establish_replication to false:

```
default[:establish_replication] = false
default[:failover] = true
```

2: Upload and apply


Notes
-----
* Deployments must be done on both environments to keep the application code up to date
* Custom recipes must be applied on both environments to keep configurations up to date
