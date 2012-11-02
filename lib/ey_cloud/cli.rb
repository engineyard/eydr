require 'thor'
require 'ey_cloud/setup'
module EYCloud
  class CLI < ::Thor
    desc "setup [--account ACCOUNT --config CONFIG_FILE ]",
      "Configure replication between environments specified in CONFIG_FILE"
    long_desc <<-DESC
      Configures an ssh tunnel and replication in PostgreSQL 9.1 between two environments specified
      in a configuration file.  It is useful for configuring a disaster recovery environment in another region.  
      
      The following options must be configured in a yaml file:
      
      dr: 
        master_public_hostname: <Amazon public hostname of live environment db_master>
        slave_public_hostname: <Amazon public hostname of disaster recovery environment db_master>
        master_pass: <Password in /root/.pgpass of live environment db_master>
        master_environment_name: <Cloud environment name of live environment>
        slave_environment_name: <Cloud environment name of disaster_recovery environment>      

    DESC
    method_option :account, :type => :string, :aliases => %w(-c),
      :required => false, :default => '',
      :desc => "Name of the account in which the application can be found"
    method_option :config, :type => :string, :aliases => %w(-f),
      :required => false, :default => 'config.yml',
      :desc => "Environment in which to apply recipes"
    def setup
      Setup.new(options).setup
    end
  end
end
