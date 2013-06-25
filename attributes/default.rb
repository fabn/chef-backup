# Some default values for backup stuff

# This is used by duplicity to store cached stuff to keep across backups
default[:duplicity][:archive_path] = '/var/cache/duplicity'
# Default paths to exclude in a full backup, /var/lib/mysql is included because
# it's useless to take filesystem snapshots unless tables are flushed and locked
default[:duplicity][:default_excludes] = %w(/proc /sys /mnt /tmp /var/lib/mysql)

# Empty attributes to override when duplicity_full recipe is used
default[:duplicity][:full][:target] = nil
default[:duplicity][:full][:target_user] = nil
default[:duplicity][:full][:target_pass] = nil
default[:duplicity][:full][:european_bucket] = false
default[:duplicity][:full][:encryption_password] = nil
default[:duplicity][:full][:exclude] = node[:duplicity][:default_excludes]

# Empty attributes to override when duplicity_mysql recipe is used
default[:duplicity][:mysql][:target] = nil
default[:duplicity][:mysql][:target_user] = node[:duplicity][:full][:target_user]
default[:duplicity][:mysql][:target_pass] = node[:duplicity][:full][:target_pass]
default[:duplicity][:mysql][:european_bucket] = node[:duplicity][:full][:european_bucket]
default[:duplicity][:mysql][:encryption_password] = node[:duplicity][:full][:encryption_password]


# EBS snapshots to keep with ec2-consistent-snapshot recipe
default[:backup][:consistent_snapshots][:expire] = false
default[:backup][:consistent_snapshots][:keep] = 7