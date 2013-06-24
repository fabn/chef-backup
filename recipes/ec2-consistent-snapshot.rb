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

# Schedule a daily snapshot of mounted volumes

# Schedule deletion of expired snapshots