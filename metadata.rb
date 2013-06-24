name             'backup'
maintainer       'Fabio Napoleoni'
maintainer_email 'f.napoleoni@gmail.com'
license          'Apache 2.0'
description      'Installs/Configures backup'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'system_base', '~> 0.1.3'
depends 'logrotate'

%w(ubuntu debian).each do |os|
  supports os
end
