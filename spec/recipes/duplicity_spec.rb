require 'spec_helper'

describe 'backup::duplicity' do

  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'should install required packages' do
    expect(chef_run).to install_package('duply')
    expect(chef_run).to install_package('duplicity')
  end

  it 'should install duply 1.5.10' do
    expect(chef_run).to render_file('/usr/bin/duply').with_content('1.5.10')
  end

  it 'should create profiles folder' do
    expect(chef_run).to create_directory('/etc/duply').
                            with_user('root').with_group('root').with_mode('0700')
  end

  it 'should create cache folder' do
    expect(chef_run).to create_directory('/var/cache/duplicity').
                            with_user('root').with_group('root').with_mode('0700')
  end

  it 'should add logrotate configuration' do
    expect(chef_run).to install_package 'logrotate'
    expect(chef_run).to render_file('/etc/logrotate.d/duplicity').with_content('/var/log/duplicity.log')
  end

end