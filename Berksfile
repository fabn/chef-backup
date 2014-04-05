site :opscode

metadata

cookbook 'system_base', '~> 0.2.0', github: 'fabn/system_base_cookbook'
cookbook 'mysql_role', '~> 0.1.0', github: 'fabn/chef-mysql_role'

group :integration do
  cookbook 'backup_test', :path => './test/cookbooks/backup_test'
end
