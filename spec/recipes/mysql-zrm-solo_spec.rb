require 'spec_helper'

describe 'backup::mysql-zrm-solo' do

  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  before do
    stub_command('which mysql-zrm').and_return(true)
  end

  it 'should include recipe for mysql configuration' do
    expect(chef_run).to include_recipe 'mysql_role::shell_config'
  end

  it 'should install required packages' do
    expect(chef_run).to install_package('libxml-parser-perl')
    expect(chef_run).to install_package('mailutils')
  end

  context 'when mysql-zrm is not installed' do

    before do
      stub_command('which mysql-zrm').and_return(false)
    end

    it 'should download its package' do
      expect(chef_run).to create_remote_file_if_missing('/tmp/mysql-zrm_2.2.0_all.deb')
    end

    it 'should install it' do
      expect(chef_run).to install_dpkg_package('/tmp/mysql-zrm_2.2.0_all.deb')
    end

  end

  it 'should create global options file' do
    expect(chef_run).to render_file('/etc/mysql-zrm/mysql-zrm.conf').with_content('backup-mode=logical')
  end

  it 'should create an empty backup set' do
    expect(chef_run).to create_directory('/etc/mysql-zrm/localhost').
                            with_owner('mysql').with_mode('0600')
    # Empty backup set configuration
    expect(chef_run).to render_file('/etc/mysql-zrm/localhost/mysql-zrm.conf').with_content('host=localhost')
  end

end
