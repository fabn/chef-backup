Feature: Backup procedures for MySQL and duply

  Duplicity MySQL recipe configures two duply profiles which are automatically
  executed using cron on the target machine.

  You can execute mysql backups also manually using the following commands.

  Duply archives are stored in `default[:duplicity][:mysql][:target]` path.

  Background: Setup a test database
    Given I set the environment variables to:
      | variable | value |
      | HOME     | /root |
    And a database named "fixtures" exist
    And there are no backups in the system

  Scenario: Doing a MySQL full backup
    Given I successfully run `duply mysql_zrm_full backup_purge_purge-full --force`
    When I run `duply mysql_zrm_full status`
    And I run `mysql-zrm-reporter --where backup-level=0 --show backup-status-info`
    Then the output from "duply mysql_zrm_full status" should contain "Full"
    And the output from "duply mysql_zrm_full status" should contain "Chain start time:"
    And the output from "mysql-zrm-reporter --where backup-level=0 --show backup-status-info" should contain "Backup succeeded"

  Scenario: Doing a MySQL incremental backup
    Given I successfully run `duply mysql_zrm_incremental backup_purge_purge-full --force`
    When I run `duply mysql_zrm_incremental status`
    And I run `mysql-zrm-reporter --where backup-level=1 --show backup-status-info`
    And the output from "duply mysql_zrm_incremental status" should contain "Chain start time:"
    And the output from "mysql-zrm-reporter --where backup-level=1 --show backup-status-info" should contain "Backup succeeded"
