EY Cloud Disaster Recovery
==========================

Pre-Requisites (EY)
-------------------
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

5. Add the SSH key generated in step 4 to the dashboard so that it is added to the deloy user's authorized_keys file.

6. Ensure a knife.rb file is configured on your local machine:

```
node_name           “solo”
data_bag_path       "<cookbook_path>/data_bags"
```

7. Create a json file containing a public and private key to be used by the SSH tunnel. Replace any carriage returns with \n so that the key is on one line in the json (see dr_keys.json.example).
8. Create an encrypted data bag containing the ssh keys:

```
EDITOR=vi knife solo data bag create dr_keys <FRAMEWORK_ENV> --json-file <framework_env>.json --secret-file ~/.chef/encrypted_data_bag_secret
```

9. Update the slave environment database password to match the master environment database password.  This must be done via the awsm console and can not be done by customers. (DOC-2184)

Boot and Configure (EY or Customer)
-----------------------------------
1. In another region, configure an environment identical to the live environment and boot instances.
2. Configure the following attributes in the dr_replication cookbook:

```
default[:dr_replication] = {
  :<framework_env> => {
    :master => {
      :public_hostname => "" # The public hostname of the master database
    },
    :initiate => {
      :public_hostname => "" # The public hostname of the database you want to rsync the data from (can be db_slave)
    },
    :slave => {
      :public_hostname => "" # The public hostname of the slave database
    }
  }

  default[:use_metadata_key] => true # Set to true to pull data bag encryption key from metadata
  default[:establish_replication] = false # Set to true to establish replication during Chef run
  default[:failover] = false # Set to true to failover to D/R environment during Chef run
```

3. If you do not want to use metadata for the encryption key, upload the encryption key to /etc/chef/ on all instances:

```
for server in `ey servers -Su -e <env> --account=JobMatcher` ; do scp -o StrictHostKeyChecking=no ~/.chef/encrypted_data_bag_secret $server:/home/deploy/; ssh -o StrictHostKeyChecking=no $server 'sudo mv /home/deploy/encrypted_data_bag_secret /etc/chef/';  done
```

4. If you are using metadata for the encryption key, add it to the account as encrypted_data_bag_secret.  Replace any carriage returns with \n so that the key is on one line in the json.

5. Upload and apply Chef cookbooks:

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
