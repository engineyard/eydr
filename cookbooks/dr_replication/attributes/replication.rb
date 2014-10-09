default[:dr_replication] = {
  :master => {
    :public_hostname => "master_public_hostname",
  },
  :initiate => {
    :public_hostname => "initiate_public_hostname"
  },
  :slave => {
    :public_hostname => "slave_public_hostname"
  },
  :xtrabackup_download_url => "http://www.percona.com/redir/downloads/XtraBackup/LATEST/binary/tarball/percona-xtrabackup-2.2.3-4982-Linux-x86_64.tar.gz",
  :qpress_download_url => "http://www.quicklz.com/qpress-11-linux-x64.tar"
}

default[:establish_replication] = false
default[:failover] = false
