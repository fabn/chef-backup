Feature: Filesystem backup with duply

  Duply profiles are configured with the `duply_profile` definition. They can be used
  to backup a given location in a duplicity target.

  In this feature the following profile has been configured:

  """
  duply_profile 'johndoe' do
    source '/home/johndoe'
    target 'file:///tmp/johndoe_backup'
    encryption_password node[:duplicity][:defaults][:encryption_password]
  end
  """

  You can execute profile backups manually using the following commands.

  Background:
    Given there are no backups in the system
    And a file named "/home/johndoe/testfile" with:
    """
    some content to backup
    """

  Scenario: Doing a backup for a given profile
    Given I successfully run `duply johndoe backup_purge_purge-full --force`
    When I run `duply johndoe status`
    Then the output should contain "Chain start time:"
    And a directory named "/tmp/johndoe_backup" should exist

  Scenario: Restoring backup to a different location
    Given I took a backup for profile "johndoe"
    When I run `duply johndoe restore /restores`
    Then the output from "duply johndoe restore /restores" should contain "Finished state OK"
    And a file named "/restores/testfile" should exist

  Scenario: Restoring backup to the same position
    Given I took a backup for profile "johndoe"
    And I run `rm -rf /home/johndoe`
    When I run `duply johndoe restore /home/johndoe`
    Then the output should contain "Finished state OK"
    And a file named "/home/johndoe/testfile" should exist
