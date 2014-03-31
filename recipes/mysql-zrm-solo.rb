#
# Cookbook Name:: backup
# Recipe:: mysql-zrm-solo
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

# Ensure mysql is configured for root to allow mysql-zrm to take backups
# using ~/.my.cnf file configured by this recipe
include_recipe 'mysql_role::shell_config'

# Download remote package, not included in usual apt repositories
remote_file "/tmp/#{File.basename(node[:mysql_zrm][:package])}" do
  source node[:mysql_zrm][:package]
  checksum node[:mysql_zrm][:checksum]
  action :create_if_missing
  not_if 'which mysql-zrm'
end

# Install package dependencies for mysql-zrm
%w(libxml-parser-perl mailutils).each { |pkg| package pkg }

dpkg_package "/tmp/#{File.basename(node[:mysql_zrm][:package])}" do
  action :install
  not_if 'which mysql-zrm'
end

# Global options for all backup set
template '/etc/mysql-zrm/mysql-zrm.conf' do
  source 'mysql-zrm.conf.erb'
  owner 'mysql'
  group 'mysql'
  mode '0600'
end

# Configure an empty backup set (which will take all defaults from above file)
directory '/etc/mysql-zrm/localhost' do
  owner 'mysql'
  group 'mysql'
  mode '0600'
end

file '/etc/mysql-zrm/localhost/mysql-zrm.conf' do
  content 'host=localhost'
  owner 'mysql'
  group 'mysql'
  mode '0600'
end
