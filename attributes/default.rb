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
