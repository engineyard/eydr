Database Failover for Engine Yard Cloud
=======================================

This is a cookbook that contains recipes for failing over to a disaster recovery environment.  The cookbook also configures monitoring on a db_master instance acting as a slave for hot standby purposes in case of a disaster in the AWS region hosting the live environment.  Replication must be re-established by Engine Yard after a failover.

A failover is triggered by updating an attribute (see below) then uploading and applying the cookbooks to the D/R environment.  The D/R environment should also be specified in the attributes of this cookbook.

Attributes configurable in attributes/default.rb
------------------------------------------------
```
default[:dr_failover] = false # Set to true to trigger a failover next time the cookbooks are uploaded and applied
default[:dr_environment_name] = "<INSERT D/R ENVIRONMENT NAME>"
```
