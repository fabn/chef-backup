And(/^no backup exist in the system for profile "([^"]*)"$/) do |profile|
  FileUtils.rmtree Dir.glob("/var/cache/duplicity/#{profile}/*")
end

And(/^there are no backups in the system$/) do
  FileUtils.rmtree Dir.glob('/var/cache/duplicity/*')
  FileUtils.rmtree('/tmp/full_backup')
  FileUtils.rmtree('/tmp/mysql_backup')
  FileUtils.rmtree('/tmp/duplicity_home_folders')
end
