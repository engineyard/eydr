default[:dr_replication] = {
  :master => {
    #:public_hostname => "ec2-54-196-151-30.compute-1.amazonaws.com" # postgres
    :public_hostname => "ec2-54-161-226-5.compute-1.amazonaws.com"
  },
  :initiate => {
    #:public_hostname => "ec2-54-196-151-30.compute-1.amazonaws.com" # postgres
    :public_hostname => "ec2-54-161-226-5.compute-1.amazonaws.com"
  },
  :slave => {
    #:public_hostname => "ec2-54-185-193-191.us-west-2.compute.amazonaws.com" # postgres
    :public_hostname => "ec2-54-212-181-144.us-west-2.compute.amazonaws.com"
  },
  :xtrabackup_download_url => "http://www.percona.com/redir/downloads/XtraBackup/LATEST/binary/tarball/percona-xtrabackup-2.2.5-5027-Linux-x86_64.tar.gz",
  :qpress_download_url => "http://www.quicklz.com/qpress-11-linux-x64.tar"
}

default[:establish_replication] = false
default[:failover] = false
