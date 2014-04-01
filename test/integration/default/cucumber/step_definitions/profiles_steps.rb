And(/^no backup exist in the system for profile "([^"]*)"$/) do |profile|
  FileUtils.rmtree Dir.glob("/var/cache/duplicity/#{profile}/*")
end

And(/^there are no backups in the system$/) do
  FileUtils.rmtree Dir.glob('/var/cache/duplicity/*')
  FileUtils.rmtree Dir.glob('/tmp/*_backup')
end

Given(/^I took a backup for profile "([^"]*)"$/) do |profile|
  steps %Q{
    Given I successfully run `duply #{profile} backup_purge_purge-full --force`
  }
end

And(/^the restore directory is empty$/) do
  FileUtils.rmtree(Dir.glob('/restores/*'))
end
