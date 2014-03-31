require 'spec_helper'

describe 'Backups' do

  describe cron do

    %w(filesystem_full mysql_zrm_incremental mysql_zrm_full).each do |profile|
      it { should have_entry("/usr/bin/duply #{profile} backup_purge_purge-full --force") }
    end

  end

  describe 'Duply profiles' do

    %w(filesystem_full mysql_zrm_incremental mysql_zrm_full).each do |profile|
      describe file("/etc/duply/#{profile}") do

        it { should be_directory }
        it { should be_owned_by('root') }
        it { should be_readable.by('owner') }
        it { should_not be_readable.by('group') }
        it { should_not be_readable.by('others') }

      end
    end

  end

end