
begin
  require 'aruba/cucumber'
rescue LoadError
  require 'rubygems/dependency_installer'
  Gem::DependencyInstaller.new.install('aruba')
  require 'aruba/cucumber'
end
