#
# Cookbook Name:: backup
# Recipe:: ec2-consistent-snapshot
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

# ensure mysql_config is run, used to write ~/.my.cnf, since ec2-consistent-snapshot
# flushes and freezes mysql databases while snapshot is taken
include_recipe 'system_base::mysql_config'

# Add alestic ppa repository, provides ec2-consistent-snapshot and ec2-expire-snapshots
apt_repository 'alestic' do
  uri 'http://ppa.launchpad.net/alestic/ppa/ubuntu'
  distribution node['lsb']['codename']
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key '0EC7E508BE09C571'
end

# Install required packages to manage snapshots and volume ids
%w(ec2-consistent-snapshot ec2-expire-snapshots cloud-utils).each do |pkg|
  package(pkg) { action :install }
end

# Temporarily replace original file with my fork
remote_file '/usr/bin/ec2-consistent-snapshot' do
  source 'https://raw.github.com/fabn/ec2-consistent-snapshot/autofreeze/ec2-consistent-snapshot'
  mode '0755'
  owner 'root'
  group 'root'
end

# Temporarily replace original file with my fork
remote_file '/usr/bin/ec2-expire-snapshots' do
  source 'https://raw.github.com/fabn/ec2-expire-snapshots/master/ec2-expire-snapshots'
  mode '0755'
  owner 'root'
  group 'root'
end

# Ensure aws environment recipe is loaded before including credentials file
include_recipe 'system_base::aws_environment'

# This file is created by system_base::aws_environment recipe
aws_environment = '[ -r /etc/profile.d/aws-environment.sh ] && . /etc/profile.d/aws-environment.sh;'
# if node has mysql use it into snapshot
snapshot_command = "#{aws_environment} ec2-consistent-snapshot -a -f -q"
snapshot_command << ' --mysql --mysql-master-status-file /var/lib/mysql/master.status' if node.recipes.include?('mysql::server')

# Schedule a daily snapshot of mounted volumes
cron 'daily ebs snapshot' do
  command snapshot_command
  hour rand(node[:backup][:hour_range])
  minute rand(node[:backup][:minute_range])
end

# Schedule deletion of expired snapshots
cron 'ebs snapshot expiration' do
  # Keep daily snapshots of last week, weekly snapshots for the last month, monthly snapshots for the last 6 month
  command "#{aws_environment} ec2-expire-snapshots -q -a --keep-first-daily 7 --keep-first-weekly 4 --keep-first-monthly 6"
  hour rand(node[:backup][:hour_range])
  minute rand(node[:backup][:minute_range])
end if node[:backup][:consistent_snapshots][:expire]
