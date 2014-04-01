require 'spec_helper'

# This inherently tests the duply_profile definition
describe 'backup::duplicity_mysql' do

  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      # Specify a target for backup
      node.set[:duplicity][:mysql][:target] = 'file:///tmp/mysql_backup'
      # Fixes hour ranges for cron execution
      node.set[:backup][:hour_range] = 2..2
      node.set[:backup][:minute_range] = 35..35
    end.converge(described_recipe)
  end

  before do
    stub_command('test -d /etc/duply/mysql_zrm_incremental').and_return(false)
    stub_command('test -d /etc/duply/mysql_zrm_full').and_return(false)
    stub_command('which mysql-zrm').and_return(true)
  end

  it 'should include mysql zrm recipe' do
    expect(chef_run).to include_recipe 'backup::mysql-zrm-solo'
  end

  it 'should create profile folders (using "duply <profile_name> create")' do
    expect(chef_run).to run_execute('duply mysql_zrm_incremental create')
    expect(chef_run).to run_execute('duply mysql_zrm_full create')
  end

  it 'should create profile configurations' do
    expect(chef_run).to render_file('/etc/duply/mysql_zrm_incremental/conf').
                            with_content("TARGET='file:///tmp/mysql_backup'")
    expect(chef_run).to render_file('/etc/duply/mysql_zrm_full/conf').
                            with_content("TARGET='file:///tmp/mysql_backup'")
  end

  it 'should not create an exclusion file' do
    expect(chef_run).to_not render_file('/etc/duply/mysql_zrm_incremental/exclude')
    expect(chef_run).to_not render_file('/etc/duply/mysql_zrm_full/exclude')
  end

  it 'should create pre script to dump databases in specified folders' do
    expect(chef_run).to render_file('/etc/duply/mysql_zrm_incremental/pre')
                        .with_content('mysql-zrm-scheduler --now --backup-set localhost --backup-level 1')
    expect(chef_run).to render_file('/etc/duply/mysql_zrm_full/pre')
                        .with_content('mysql-zrm-scheduler --now --backup-set localhost --backup-level 0')
  end

  it 'should create post script to purge mysql-zrm old backups' do
    expect(chef_run).to render_file('/etc/duply/mysql_zrm_incremental/post')
                        .with_content('mysql-zrm-purge --backup-set localhost')
    expect(chef_run).to render_file('/etc/duply/mysql_zrm_full/post')
                        .with_content('mysql-zrm-purge --backup-set localhost')
  end

end
