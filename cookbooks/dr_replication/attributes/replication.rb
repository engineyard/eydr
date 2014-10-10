default[:dr_replication] = {
  :use_metadata_key => true,
  :master => {
    :public_hostname => "ec2-54-234-251-237.compute-1.amazonaws.com"
  },
  :initiate => {
    :public_hostname => "ec2-54-234-251-237.compute-1.amazonaws.com"
  },
  :slave => {
    :public_hostname => "ec2-54-184-170-30.us-west-2.compute.amazonaws.com"
  },
  :xtrabackup_download_url => "http://www.percona.com/redir/downloads/XtraBackup/LATEST/binary/tarball/percona-xtrabackup-2.2.5-5027-Linux-x86_64.tar.gz",
  :qpress_download_url => "http://www.quicklz.com/qpress-11-linux-x64.tar"
}

default[:establish_replication] = false
default[:failover] = false
