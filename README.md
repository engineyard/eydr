EY Cloud Disaster Recovery
==========================

Steps to Configure
------------------
1. Add yourself as collaborator to the account
2. SSH into each database master instance as the deploy user to ensure your key has been added
3. In another region, configure an environment identical to the live environment.
4. Edit the following values in config.yml.example and rename to config.yml:
  * master database hostname 
  * slave database hostname
  * master environment name
  * slave environment name
  * master database password
  * database type
  * master region (MySQL only)
  * slave region (MySQL only)
  * master database instance id (MySQL only)
  * slave database instance id (MySQL only)
  * AWS access key id (MySQL only)
  * AWS secret access key  (MySQL only)
5. ronin open each environment to install your SSH key
6. 4. Ensure you are collaborator on the account
7. . Take a snapshot on the master environment
8. . Update the password on the D/R environment to match the password on the current live environment 
  * See:  https://engineyard.jiveon.com/docs/DOC-1234
9. Run setup to generate and run Chef recipes on master and slave environments:
  * bundle exec bin/eydr setup --account <account name> --config <config file location>
10. Download latest recipes and update main custom Chef recipe:
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
