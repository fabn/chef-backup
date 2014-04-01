Feature: Backup procedures with MySQL ZRM

  With MySQL ZRM is configured in the system using mysql-zrm-solo recipe you can run mysql
  backups (both full and incremental) of all databases.

  Default backup set configured by recipe is named localhost which uses default settings
  configured in the system by recipe, i.e.:

    - backup-mode=logical
    - backup-type=regular
    - compress=1
    - all-databases=1
    - mysql-binlog-path=/var/log/mysql
    - mailto=root@localhost
    - mail-policy=only-on-error
    - copy-plugin=/usr/share/mysql-zrm/plugins/ssh-copy.pl
    - retention-policy=10D

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
    When I run command `mysql-zrm-restore --backup-set localhost --source-directory $(cat /etc/mysql-zrm/localhost/last_backup)`
    Then the output from last command should contain "Restored database(s)"
    And the database "fixtures" should exist

  Scenario: Partial restore of a backup
    Given a database named "other" exist
    And I succesfully took a backup with mysql-zrm for backup set "localhost"
    And I drop the database "fixtures"
    And I drop the database "other"
    When I run command `mysql-zrm-restore --backup-set localhost --source-directory $(cat /etc/mysql-zrm/localhost/last_backup) --databases other`
    Then the output from last command should contain "Restored database(s)"
    And the database "fixtures" should not exist
    And the database "other" should exist
