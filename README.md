# backup cookbook

This cookbook contains backup utilities I've used in various setups.

Includes strategy for making backups using the following tools/strategies:

* Duplicity/Duply
* MySQL ZRM

# Requirements

This cookbook have the following dependencies:

* `logrotate` (opscode) for rotating duplicity logfiles
* `system_base` to load encrypted databags as node attributes

# Attributes

Attributes which should be set
------------------------------

* `node[:duplicity][:full][:target]` duplicity [target](http://duplicity.nongnu.org/duplicity.1.html#sect8) to use when
 doing full filesystem backups with `duplicity_full` recipe.
* `node[:duplicity][:full][:target_user]` username to use if not embedded in `target`
* `node[:duplicity][:full][:target_pass]` password to use if not embedded in `target`
* `node[:duplicity][:full][:european_bucket]` (default false) if true an european bucket will be used for S3 targets
* `node[:duplicity][:full][:encryption_password]` (default nil) if given backup will be symmetrically encrypted

Attributes which should not require tuning
------------------------------------------

* `node[:duplicity][:archive_path]` (default `/var/cache/duplicity`) path used by duplicity to store cached stuff used
  to improve bandwidth usage and backup time for incremental backups

# Recipes

* `duplicity`: Install and configure [duplicity](http://duplicity.nongnu.org/) and its wrapper [duply](http://duply.net/)
* `duplicity_full`: Configure duplicity to take daily backups of full filesystem and store them in the given target

Currently for duplicity stuff no GPG signing is implemented, only symmetric encryption is available

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
duply_profile "user\_home\_s3" do
  source '/home/user'
  target 's3://<bucket>/<prefix>'
end
```

Use all possible attributes (including defaults one)

```ruby
duply_profile "user\_home\_s3" do
  source '/home/user'
  target 's3://<bucket>/<prefix>'
  interval :daily
  pre_script 'do something'
  post_script 'do something else'
  enable true # if false backup won't be scheduled by cron
end
```

# Author

Author:: Fabio Napoleoni (<f.napoleoni@gmail.com>)
