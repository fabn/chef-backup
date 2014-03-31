require 'spec_helper'

# This inherently tests the duply_profile definition
describe 'backup::duplicity_full' do

  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      # Specify a target for backup
      node.set[:duplicity][:full][:target] = 'file:///tmp/full_backup'
      # Fixes hour ranges for cron execution
      node.set[:backup][:hour_range] = 2..2
      node.set[:backup][:minute_range] = 35..35
    end.converge(described_recipe)
  end

  before do
    stub_command('test -d /etc/duply/filesystem_full').and_return(false)
  end

  it 'should include duplicity recipe' do
    expect(chef_run).to include_recipe 'backup::duplicity'
  end

  it 'should create profile folder (using "duply <profile_name> create")' do
    expect(chef_run).to run_execute('duply filesystem_full create')
  end

  it 'should create profile configuration' do
    expect(chef_run).to render_file('/etc/duply/filesystem_full/conf').
                            with_content("TARGET='file:///tmp/full_backup'")
  end

  it 'should create exclusion file' do
    expect(chef_run).to render_file('/etc/duply/filesystem_full/exclude').
                            with_content(%w(/proc /sys /mnt /tmp /var/lib/mysql).join("\n"))
  end

end