#
# Cookbook Name:: backup_test
# Recipe:: default
#
# Copyright (C) 2014 Fabio Napoleoni
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Private recipe used only in integration tests

user 'johndoe'

# Configure backups for an hypotetical user home
duply_profile 'johndoe' do
  source '/home/johndoe'
  target 'file:///tmp/johndoe_backup'
  encryption_password node[:duplicity][:defaults][:encryption_password]
end
