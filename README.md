EY Cloud Disaster Recovery for PostgreSQL 9.1
=============================================

Steps to Configure
------------------
1. In another region, configure an environment identical to the live environment.
2. Edit the following values in config.yml.example and rename to config.yml:
  * master database hostname 
  * slave database hostname
  * master environment name
  * slave environment name
  * master database password
4. Run setup to generate and run Chef recipes on master and slave environments:
  * bundle exec bin/eydr setup --account <account name> --config <config file location>
5. Download latest recipes and update main custom Chef recipe:
  * ey recipes download --environment <master environment name>
  * Add to cookbooks/main/recipes/default.rb: #require_recipe "db_failover"

Steps to Failover
-----------------
1. Enable db_failover cookbook in main cookbook
  * Uncomment in cookbooks/main/recipes/default.rb:  require_recipe "db_failover"
2. Apply recipes
  * ey recipes upload --apply --environment <slave environment name>
3. Verify db_master in DR environment is now master
  * "ps -efa | grep receiver" should not show a receiver process
4. Remove db_failover require from main cookbook
  * Comment in cookbooks/main/recipes/default.rb: #require_recipe "db_failover"
  
Notes
-----
* Deployments must be done on both environments to keep the application code up to date
* Custom recipes must be applied on both environments to keep configurations up to date