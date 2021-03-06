# Definition for configuring a duply profile on the system

define :duply_profile,
       :interval => :daily,
       :enable => true do

  include_recipe 'backup::duplicity'

  profile_name = params[:name]

  # invoke duply create profile
  execute "create duply profile #{profile_name}" do
    command "duply #{profile_name} create"
    not_if "test -d /etc/duply/#{profile_name}"
  end

  template_var_keys = [:source, :target, :target_user, :target_pass, :european_bucket, :encryption_password]
  template_variables = params.select { |k,_| template_var_keys.include? k.to_sym }

  # Configure profile through template
  template "/etc/duply/#{profile_name}/conf" do
    source 'profile_conf.erb'
    cookbook 'backup'
    owner 'root'
    group 'root'
    mode '0600'
    variables template_variables
  end

  # Excludes glob file list for this profile
  excludes = params[:exclude] ? params[:exclude] : node[:duplicity][:default_excludes]
  excludes = excludes.join("\n") if excludes.is_a? Array
  # Populate exclude file with retrieved list
  file "/etc/duply/#{profile_name}/exclude" do
    content excludes
  end if params[:exclude]

  # pre and post script
  file "/etc/duply/#{profile_name}/pre" do
    content params[:pre_script]
  end unless params[:pre_script].nil?

  file "/etc/duply/#{profile_name}/post" do
    content params[:post_script]
  end unless params[:post_script].nil?

  # Enable its execution using cron
  if params[:enable]

    case params[:interval]
      when :daily
        # run every day
        day, weekday = '*', '*'
      when :weekly
        # run every sunday
        day, weekday = '*', '0'
      when :monthly
        # run every first day of the month
        day, weekday = '1', '*'
      else
        # if other values run daily
        day, weekday = '*', '*'
    end

    # Add a crontab entry
    cron "duply_#{profile_name}_#{params[:interval]}" do
      command "/usr/bin/duply #{profile_name} backup_purge_purge-full --force > /dev/null"
      hour rand(node[:backup][:hour_range])
      minute rand(node[:backup][:minute_range])
      day day
      weekday weekday
    end
  end

end
