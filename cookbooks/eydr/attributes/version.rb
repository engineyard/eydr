case node['dna']['engineyard']['environment']['db_stack_name']
when "mysql"
  mysql :latest_version => "5.0.51", :virtual => "5.0", :short_version => '5.0'
  datadir '/db/mysql/'
when "mysql5_1"
  mysql :latest_version => "5.1.55", :virtual => "5.1", :short_version => '5.1'
  datadir '/db/mysql/5.1/data/'
when "mysql5_5"
  mysql :latest_version => "5.5.31", :virtual => "5.5", :short_version => '5.5'
  datadir '/db/mysql/5.5/data/'
when "mysql5_6"
  mysql :latest_version => "5.6.14", :virtual => "5.6", :short_version => '5.6'
  datadir '/db/mysql/5.6/data/'
when "postgres9"
  postgresql :latest_version => "9.0.13", :short_version => "9.0"
  datadir '/db/postgresql/9.0/data'
when "postgres9_1"
  postgresql :latest_version => "9.1.9", :short_version => "9.1"
  datadir '/db/postgresql/9.1/data'
when "postgres9_2"
  postgresql :latest_version => "9.2.7", :short_version => "9.2"
  datadir '/db/postgresql/9.2/data'
when "postgres9_3"
  postgresql :latest_version => "9.3.3", :short_version => "9.3"
  datadir '/db/postgresql/9.3/data'
end
