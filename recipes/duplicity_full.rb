#
# Cookbook Name:: backup
# Recipe:: duplicity_full
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

unless node[:duplicity][:full][:target]
  Chef::Application.fatal! 'You must define node[:duplicity][:full][:target] to use this recipe'
end

duply_profile 'filesystem_full' do
  source '/'
  target node[:duplicity][:full][:target]
  target_user node[:duplicity][:full][:target_user]
  target_pass node[:duplicity][:full][:target_pass]
  european_bucket node[:duplicity][:full][:european_bucket]
  encryption_password node[:duplicity][:full][:encryption_password]
  interval :daily
end
