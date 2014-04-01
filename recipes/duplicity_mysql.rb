#
# Cookbook Name:: backup
# Recipe:: duplicity_mysql
#
# Copyright (C) 2013 Fabio Napoleoni
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

unless node[:duplicity][:mysql][:target]
  Chef::Application.fatal! 'You must define node[:duplicity][:mysql][:target] to use this recipe'
end

# Ensure mysql-zrm is configured in solo mode
include_recipe 'backup::mysql-zrm-solo'

# Do a daily incremental backup for all databases
duply_profile 'mysql_zrm_incremental' do
  source '/var/lib/mysql-zrm'
  target node[:duplicity][:mysql][:target]
  target_user node[:duplicity][:mysql][:target_user]
  target_pass node[:duplicity][:mysql][:target_pass]
  european_bucket node[:duplicity][:mysql][:european_bucket]
  encryption_password node[:duplicity][:mysql][:encryption_password]
  interval :daily
  pre_script 'mysql-zrm-scheduler --now --backup-set localhost --backup-level 1'
  post_script 'mysql-zrm-purge --backup-set localhost'
end

# Do a weekly full backup for all databases
duply_profile 'mysql_zrm_full' do
  source '/var/lib/mysql-zrm'
  target node[:duplicity][:mysql][:target]
  target_user node[:duplicity][:mysql][:target_user]
  target_pass node[:duplicity][:mysql][:target_pass]
  european_bucket node[:duplicity][:mysql][:european_bucket]
  encryption_password node[:duplicity][:mysql][:encryption_password]
  interval :weekly
  pre_script 'mysql-zrm-scheduler --now --backup-set localhost --backup-level 0'
  post_script 'mysql-zrm-purge --backup-set localhost'
end
