#
# Cookbook Name:: backup
# Recipe:: duplicity
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

%w(duplicity duply).each do |pkg|
  package(pkg) { action :install }
end

# This is needed for Ubuntu 12.04LTS, because provided package has a bug with restore.
cookbook_file '/usr/bin/duply' do
  source 'duply-1.5.10.sh'
  only_if { node[:platform] == 'ubuntu' && node[:platform_version].to_f == 12.04 }
end

directory '/etc/duply' do
  action :create
  owner 'root'
  group 'root'
  mode '0700'
end

# Create directory for duplicity cache
directory node[:duplicity][:archive_path] do
  action :create
  owner 'root'
  group 'root'
  mode '0700'
end

# Add logrotate configuration file for duplicity log file created by duply
logrotate_app 'duplicity' do
  path '/var/log/duplicity.log'
  frequency 'weekly'
  rotate 14
  options 'missingok compress delaycompress notifempty'
end
