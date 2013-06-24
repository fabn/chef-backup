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

# Download remote package, not included in usual apt repositories
remote_file "/tmp/#{File.basename(node[:mysql_zrm][:package])}" do
  source node[:mysql_zrm][:package]
  action :create_if_missing
  not_if 'which mysql-zrm'
end

# Install package dependencies for mysql-zrm
%w(libxml-parser-perl bsd-mailx).each { |pkg| package pkg }

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
