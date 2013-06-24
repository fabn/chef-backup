# Some default values for backup stuff

# This is used by duplicity to store cached stuff to keep across backups
default[:duplicity][:archive_path] = '/var/cache/duplicity'

# Empty attributes to override when duplicity_full recipe is used
default[:duplicity][:full][:target] = nil
default[:duplicity][:full][:target_user] = nil
default[:duplicity][:full][:target_pass] = nil
default[:duplicity][:full][:european_bucket] = false
default[:duplicity][:full][:encryption_password] = nil