Restore procedures for automatic backups
========================================

Duply/Duplicity
---------------

### Restore file profiles

Assuming you have a profile named `apache-web-root` that backups web server root then you can restore it in its
original position from latest backup with:

```bash
export dest=/var/www/
export profile=apache-web-root
rm -rf $dest
duply $profile restore $dest
```

To restore into a new location (which shouldn't exist) just change the last parameter of restore call

```bash
export dest=/var/www2/
export profile=apache-web-root
duply $profile restore $dest
```

To restore only part of a given backup use the `fetch` command

```bash
export dest=/var/www/
export profile=apache-web-root
# relative path of what to restore, this will restore original /var/www/some_folder into dest path
export what=some_folder
rm -rf /var/www/some_folder
duply $profile fetch $what $dest
```

### Restore mysql-zrm backups with duply

Duplicity is automatically configured to take backups (possibly offsite) of `/var/lib/mysql-zrm` folder which
 contains latest mysql backups.

If you lost this directory you might need to restore it using duply from an archived copy with these commands

```bash
rm -rf /var/lib/mysql-zrm
duply mysql_zrm_full restore /var/lib/mysql-zrm
```

Mysql ZRM restore
-----------------

Once mysql zrm backups are restored with duply you need to restore databases, to do that you need to set a variable
with your backup set name, i.e.

```bash
export backup_set=localhost
export last_backup=`ls /var/lib/mysql-zrm/$backup_set | tail -1`
```

Tell mysql-zrm which is the last backup

```bash
echo /var/lib/mysql-zrm/$backup_set/$last_backup > /etc/mysql-zrm/$backup_set/last_backup
```

Verify it

```bash
# verify last backup
mysql-zrm-verify-backup --backup-set $backup_set
```

Restore it if is a full one

```bash
export source_directory=`cat /etc/mysql-zrm/$backup_set/last_backup`
mysql-zrm-restore --backup-set $backup_set --source-directory $source_directory

```

Otherwise you need to restore the last full one and then the other incremental ones

### Restore a full backup and all incremental backups after it

* Put mysql in read-only mode, in this way only clients with SUPER privileges can write stuff.
* Load latest full backup into database
* Load all incremental backups after the full you've restored
* Turn off read only mode

These commands will automate this task

```bash
# set some variables, you should only need to set the backup set
backup_set=localhost
# get directory of latest full backup for a given backup set
last_full=`mysql-zrm-reporter --destination /var/lib/mysql-zrm --fields backup-directory --where backup-level=0 | grep $backup_set | awk '{print $2}' | head -n 1`
last_full_basename=`basename $last_full`
# get list of incrementals backup after the full one
incrementals="`mysql-zrm-reporter --destination /var/lib/mysql-zrm --fields backup-directory --noheader --where backup-set=$backup_set | sort | awk '{print $2}' | sed "0,/$last_full_basename/d"`"
# Verify last full backup
mysql-zrm-verify-backup --backup-set $backup_set --source-directory $last_full
# Verify all involved backups
echo $incrementals | xargs -L 1 mysql-zrm-verify-backup --backup-set $backup_set --source-directory
# Do the actual restore
# With this only users with SUPER privilege can write into database
mysql -e 'SET GLOBAL read_only = ON'
# Restore last full backup
mysql-zrm-restore --backup-set $backup_set --source-directory $last_full
# Finally execute restore for each one of them using xargs with -L 1 to limit command line args to 1
echo $incrementals | xargs -L 1 mysql-zrm-restore --backup-set $backup_set --source-directory
# Disable readonly mode
mysql -e 'SET GLOBAL read_only = OFF'
```

Previous commands need mysql-reporter configured to show backup-directory all in one line. Default field width
of 40 in `/etc/mysql-zrm/mysql-zrm-reporter.conf` may not be enough. It depends on backup set name.

### Other useful mysql-zrm stuff

```bash
# backup status
mysql-zrm-reporter --where backup-set=$backup_set --show backup-status-info
# backup-performance-info
mysql-zrm-reporter --where backup-set=$backup_set--show backup-performance-info
# get list of incremental backups
mysql-zrm-reporter --show restore-info --where backup-level=1

```

### Restore a backup which is not the latest

```bash
# list backups for the given backup set
mysql-zrm-reporter --show restore-info --where backup-set=$backup_set
# manually selecting backup to restore
export source_directory='<cut and paste output of last command>'
# find last backup directory
mysql-zrm-restore --backup-set $backup_set --source-directory $source_directory
```
