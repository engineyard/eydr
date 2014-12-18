default[:dr_replication] = {
  :staging => {
    :master => {
      #:public_hostname => "ec2-184-72-139-246.compute-1.amazonaws.com" #eydr_mysql56_test_db_master
      #:public_hostname => "ec2-54-91-78-169.compute-1.amazonaws.com" #eydr_mysql55_test_db_master
      #:public_hostname => "ec2-54-166-140-189.compute-1.amazonaws.com" #eydr_psql92_test_db_master
      :public_hostname => "ec2-54-160-108-11.compute-1.amazonaws.com" #eydr_psql93_test_db_master
    },
    :initiate => {
      #:public_hostname => "ec2-184-72-139-246.compute-1.amazonaws.com" #eydr_mysql56_test_db_master
      #:public_hostname => "ec2-54-91-78-169.compute-1.amazonaws.com" #eydr_mysql55_test_db_master
      #:public_hostname => "ec2-54-166-140-189.compute-1.amazonaws.com" #eydr_psql92_test_db_master
      :public_hostname => "ec2-54-160-108-11.compute-1.amazonaws.com" #eydr_psql93_test_db_master
    },
    :slave => {
      #:public_hostname => "ec2-54-203-25-73.us-west-2.compute.amazonaws.com" #eydr_mysql56_test_west_db_master
      #:public_hostname => "ec2-54-244-195-124.us-west-2.compute.amazonaws.com" #eydr_mysql55_test_west_db_master
      #:public_hostname => "ec2-54-202-192-88.us-west-2.compute.amazonaws.com" #eydr_psql92_test_west_db_master
      :public_hostname => "ec2-54-189-46-43.us-west-2.compute.amazonaws.com" #eydr_psql93_test_west_db_master
    }
  },
  # The following 2 URLs are required for MySQL replication
  :xtrabackup_download_url => "http://www.percona.com/redir/downloads/XtraBackup/LATEST/binary/tarball/percona-xtrabackup-2.2.6-5042-Linux-x86_64.tar.gz",
  :qpress_download_url => "http://www.quicklz.com/qpress-11-linux-x64.tar",
  # Set to true to pull data bag encryption key from metadata
  :use_metadata_key => true
}

# Set to true to establish replication during Chef run
default[:establish_replication] = true

# Set to true to failover to D/R environment during Chef run1
default[:failover] = false
