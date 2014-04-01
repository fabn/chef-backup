Feature: Backup procedures with MySQL ZRM

  With MySQL ZRM is configured in the system using mysql-zrm-solo recipe you can run mysql
  backups (both full and incremental) of all databases.

  Background: Setup a test database
    Given I set the environment variables to:
      | variable   | value     |
      | HOME       | /root     |
    And a database named "fixtures" exist
    And there are no mysql-zrm backups in the system

  Scenario: Doing a MySQL full backup
    Given I successfully run `mysql-zrm-scheduler --now --backup-set localhost --backup-level 0`
    When I run `mysql-zrm-reporter --where backup-level=0 --where backup-set=localhost --show backup-status-info`
    Then the output should contain "Backup succeeded"
    And a directory named "/var/lib/mysql-zrm/localhost/" should exist
    And a file named "/etc/mysql-zrm/localhost/last_backup" should exist

  Scenario: Verify a taken backup
    Given I succesfully took a backup with mysql-zrm for backup set "localhost"
    When I run `mysql-zrm-verify-backup --backup-set localhost`
    Then the output should contain "Verification successful"

  Scenario: Restore previous backup
    Given I succesfully took a backup with mysql-zrm for backup set "localhost"
    And I drop the database "fixtures"
    When I run `mysql-zrm-restore --backup-set localhost --source-directory $(cat /etc/mysql-zrm/localhost/last_backup)`
    Then the output should contain "Restored database(s)"
    And the database "fixtures" should exist
