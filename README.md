# backup cookbook [![Build Status](https://travis-ci.org/fabn/chef-backup.svg)](https://travis-ci.org/fabn/chef-backup)

This cookbook contains backup utilities I've used in various setups.

Includes strategy for making backups using the following tools/strategies:

* Duplicity/Duply
* MySQL ZRM

# Requirements

This cookbook have the following dependencies:

* `logrotate` (opscode) for rotating duplicity logfiles
* `system_base` to load encrypted databags as node attributes
* `mysql_role` to configure mysql user files

See also

* [mysql_role](https://github.com/fabn/chef-mysql_role) cookbook

# Attributes

Attributes which should be set
------------------------------

These attributes are used to configure duplicity profiles

* `node[:duplicity][:defaults][:target]` duplicity [target](http://duplicity.nongnu.org/duplicity.1.html#sect8) to use when
 doing duplicity backups.
* `node[:duplicity][:defaults][:target_user]` username to use if not embedded in `target`
* `node[:duplicity][:defaults][:target_pass]` password to use if not embedded in `target`
* `node[:duplicity][:defaults][:european_bucket]` (default false) if true an european bucket will be used for S3 targets
* `node[:duplicity][:defaults][:encryption_password]` (default nil) if given backup will be symmetrically encrypted

Attributes which should not require tuning
------------------------------------------

These attributes are used to configure the `duplicity_full` recipe and override defaults above

* `node[:duplicity][:full][:target]` default `"#{node[:duplicity][:defaults][:target]}_files"`
* `node[:duplicity][:full][:target_user]` username to use if not embedded in `target`
* `node[:duplicity][:full][:target_pass]` password to use if not embedded in `target`
* `node[:duplicity][:full][:european_bucket]` (default false) if true an european bucket will be used for S3 targets
* `node[:duplicity][:full][:encryption_password]` (default nil) if given backup will be symmetrically encrypted
* `node[:duplicity][:full][:exclude]` (default `node[:duplicity][:default_excludes]`) paths to exclude in a full backup

These attributes are used to configure the `duplicity_mysql` recipe and override defaults above

* `node[:duplicity][:mysql][:target]` default `"#{node[:duplicity][:defaults][:target]}_mysql"`
* `node[:duplicity][:mysql][:target_user]` username to use if not embedded in `target`
* `node[:duplicity][:mysql][:target_pass]` password to use if not embedded in `target`
* `node[:duplicity][:mysql][:european_bucket]` (default false) if true an european bucket will be used for S3 targets
* `node[:duplicity][:mysql][:encryption_password]` (default nil) if given backup will be symmetrically encrypted

Other generic attributes

* `node[:backup][:hour_range]` (default 2..5) When cron jobs are generated for backup stuff they will be generate with random
 hours in the given interval to avoid multiple jobs running at the same time potentially slowing down the whole thing.
* `node[:backup][:minute_range]` (default 0..59) same as above.
* `node[:duplicity][:archive_path]` (default `/var/cache/duplicity`) path used by duplicity to store cached stuff used
  to improve bandwidth usage and backup time for incremental backups
* `node[:duplicity][:default_excludes]` (default `%w(/proc /sys /mnt /tmp /var/lib/mysql)`) default paths excluded in a
 backup. `/var/lib/mysql` is included because it's almost useless to take filesystem snapshots unless tables are flushed
 and locked.
* `node[:mysql_zrm][:package]` url of .deb package for current version of MySQL ZRM

# Recipes

* `duplicity`: Install and configure [duplicity](http://duplicity.nongnu.org/) and its wrapper [duply](http://duply.net/)
* `duplicity_full`: Configure duplicity to take daily backups of full filesystem and store them in the given target
* `mysql-zrm-solo`: Install and configure MySQL ZRM package to take database full and incremental backups
* `duplicity_mysql`: Configure a duplicity profile which will take mysql backups and store them in the given target
* `ec2-consistent-snapshot`: Install ec2-consistent-snapshot package from ubuntu ppa:/alestic

Currently for duplicity stuff no GPG signing is implemented, only symmetric encryption is available.

MySQL zrm is not configured for encryption, you can encrypt remote backups using the `duplicity_mysql` provided recipe.

Definitions
===========

The cookbook provides a few definition to configure specific backup needs.

duply\_profile
--------------

This definition configure a duply profile (i.e. a duplicity configuration)
according to the given parameters.

### Parameters:

Mandatory params:

* `name`: duply profile name, will be used as folder name
* `source`: folder to backup
* `target`: backup target

Optional parameters:

* `enable`: (default `true`) if true backup will be scheduled with cron
* `interval`: (default `:daily`) the interval for this profile, allowed values :daily, :weekly, :monthly
* `target_user`: (default nil) target username
* `target_pass`: (default nil) target password
* `encryption_password`: (default nil) GPG symmetric passphrase to encrypt backups, if `nil` backups won't be encrypted
* `pre_script`: (default nil) shell script content to execute before the backup
* `post_script`: (default nil) shell script content to execute after the backup

### Examples:

Create a profile for backing up a given directory daily. First backup is a full one,
 then every day an incremental backup is taken and one full backup will be taken once
 per month.

```ruby
duply_profile "user_home_s3" do
  source '/home/user'
  target 's3://<bucket>/<prefix>'
end
```

Use all possible attributes (including defaults one)

```ruby
duply_profile "user_home_s3" do
  source '/home/user'
  target 's3://<bucket>/<prefix>'
  interval :daily
  pre_script 'do something'
  post_script 'do something else'
  enable true # if false backup won't be scheduled by cron
end
```

### Restore

To restore backups created with these recipes see [restore document](Restore.md)

# TODO

* Create a `duplicity_data_bag` recipe to load duply profiles from a given data bag

# Author

Author:: Fabio Napoleoni (<f.napoleoni@gmail.com>)
