EY Cloud Disaster Recovery
==========================

Pre-Requisites
-------------------
1) Generate SSH keys to be used by the SSH tunnel (do not use a passphrase)

```
ssh-keygen -t rsa -b 2048 -f ./eydr_key
```

2) Add the SSH key generated in step 4 to the dashboard so that it is added to the deploy user's authorized_keys file.

3) In another region, configure an environment identical to the live environment and boot instances.

4) An Engine Yard Support Engineer must update the slave environment database password to match the master environment database password.  This must be done via the awsm console and can not be done by customers. (DOC-2184)

5) An Engine Yard Support Engineer must add the SSH keys generated to the metadata.  The names should be eydr_private_key and eydr_public_key.  These should be added at the account level.  The carriage returns must be replaced with \n before being inputted into the metadata web interface.

Configure
---------
1) Configure the following attributes in the dr_replication cookbook:

```
default[:dr_replication] = {
  :<framework_env> => {
    :master => {
      :public_hostname => "" # The public hostname of the master database
    },
    :initiate => {
      :public_hostname => "" # The public hostname of the database you want to sync the data from (can be the slave or master)
    },
    :slave => {
      :public_hostname => "" # The public hostname of the disaster recovery database
    }
  }

  default[:establish_replication] = false # Set to true to establish replication during Chef run
  default[:failover] = false # Set to true to failover to D/R environment during Chef run
```

2) Upload and apply Chef cookbooks:

```
ey recipes upload --apply -e <master_environment_name>
ey recipes upload --apply -e <slave_environment_name>
```

Steps to Failover
-----------------
1) Set the failover attribute to true and establish_replication to false:

```
default[:establish_replication] = false
default[:failover] = true
```

2) Upload and apply

Notes
-----
* Deployments must be done on both environments to keep the application code up to date
* Custom recipes must be applied on both environments to keep configurations up to date
