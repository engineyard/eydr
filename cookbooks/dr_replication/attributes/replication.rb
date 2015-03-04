default[:dr_replication] = {
  :production => {
    :master => {
      :public_hostname => ""
    },
    :initiate => {
      :public_hostname => ""
    },
    :slave => {
      :public_hostname => ""
    }
  },
  # The following 2 URLs are required for MySQL replication
  :xtrabackup_download_url => "http://www.percona.com/redir/downloads/XtraBackup/XtraBackup-2.2.6/binary/tarball/percona-xtrabackup-2.2.6-5042-Linux-x86_64.tar.gz",
  :qpress_download_url => "http://www.quicklz.com/qpress-11-linux-x64.tar",
  # Set to true to pull data bag encryption key from metadata
  :use_metadata_key => true
}

# Set to true to establish replication during Chef run
default[:establish_replication] = false

# Set to true to failover to D/R environment during Chef run
default[:failover] = false
