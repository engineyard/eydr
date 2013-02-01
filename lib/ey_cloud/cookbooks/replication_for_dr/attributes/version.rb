case attribute['engineyard']['environment']['db_stack_name']
when "mysql"
  mysql :version => "5.0.51", :virtual => "5.0", :package => "dev-db/mysql-community", :short_version => "5.0"
when "mysql5_1"
  mysql :version => "5.1.55.12.6", :virtual => "5.1", :package => "dev-db/percona-server", :short_version => "5.1"
when "mysql5_5"
  mysql :version => "5.5.18.23.0-r1", :virtual => "5.5", :package => "dev-db/percona-server", :short_version => "5.5"
when "postgres9"
  postgresql :version => "9.0.4-r2", :virtual => "9.0", :package => "dev-db/postgresql-base", :short_version => "9.0"
when "postgres9_1"
  postgresql :version => "9.1.1", :virtual => "9.1", :package => "dev-db/postgresql-base", :short_version => "9.1"
end
