And(/^a database named "([^"]*)" exist$/) do |db_name|
  system("mysql -e 'CREATE DATABASE IF NOT EXISTS #{db_name}'")
end

And(/^I drop the database "([^"]*)"$/) do |db_name|
  system("mysql -e 'DROP DATABASE IF EXISTS #{db_name}'")
end

Then(/^the database "([^"]*)" should (not )?exist$/) do |db_name, not_exist|
  not_exist ?
      `mysql -e 'SHOW DATABASES'`.should_not(include(db_name)) :
      `mysql -e 'SHOW DATABASES'`.should(include(db_name))
end

Given(/^I succesfully took a backup with mysql-zrm for backup set "([^"]*)"$/) do |bs|
  steps %Q{
      Given I successfully run `mysql-zrm-scheduler --now --backup-set #{bs} --backup-level 0`
  }
end

And(/^there are no mysql-zrm backups in the system$/) do
  FileUtils.rmtree('/var/lib/mysql-zrm/localhost/') rescue nil
  FileUtils.rm('/etc/mysql-zrm/localhost/last_backup') rescue nil
end
