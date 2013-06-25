# Some default values for backup stuff

# This is used by duplicity to store cached stuff to keep across backups
default[:duplicity][:archive_path] = '/var/cache/duplicity'
# Default paths to exclude in a full backup, /var/lib/mysql is included because
# it's useless to take filesystem snapshots unless tables are flushed and locked
default[:duplicity][:default_excludes] = %w(/proc /sys /mnt /tmp /var/lib/mysql)

# Hour range used to generate hours for cron
default[:backup][:hour_range] = 2..5
default[:backup][:minute_range] = 60

# Default attributes used in duplicity profiles
default[:duplicity][:defaults][:target] = nil
default[:duplicity][:defaults][:target_user] = nil
default[:duplicity][:defaults][:target_pass] = nil
default[:duplicity][:defaults][:european_bucket] = false
default[:duplicity][:defaults][:encryption_password] = nil

# Empty attributes to override when duplicity_full recipe is used
default[:duplicity][:full][:target] = node[:duplicity][:defaults][:target] ? "#{node[:duplicity][:defaults][:target]}_files" : nil
default[:duplicity][:full][:target_user] = node[:duplicity][:defaults][:target_user]
default[:duplicity][:full][:target_pass] = node[:duplicity][:defaults][:target_pass]
default[:duplicity][:full][:european_bucket] = node[:duplicity][:defaults][:european_bucket]
default[:duplicity][:full][:encryption_password] = node[:duplicity][:defaults][:european_bucket]
default[:duplicity][:full][:exclude] = node[:duplicity][:default_excludes]

# Empty attributes to override when duplicity_mysql recipe is used
default[:duplicity][:mysql][:target] = node[:duplicity][:defaults][:target] ? "#{node[:duplicity][:defaults][:target]}_mysql" : nil
default[:duplicity][:mysql][:target_user] = node[:duplicity][:defaults][:target_user]
default[:duplicity][:mysql][:target_pass] = node[:duplicity][:defaults][:target_pass]
default[:duplicity][:mysql][:european_bucket] = node[:duplicity][:defaults][:european_bucket]
default[:duplicity][:mysql][:encryption_password] = node[:duplicity][:defaults][:encryption_password]


# EBS snapshots to keep with ec2-consistent-snapshot recipe
default[:backup][:consistent_snapshots][:expire] = true
default[:backup][:consistent_snapshots][:keep] = 15