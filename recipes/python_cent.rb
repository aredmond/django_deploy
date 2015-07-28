#
# Cookbook Name:: django_deploy
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved

bash "yum groupinstall Development tools" do
  user "root"
  group "root"
  code <<-EOC
    yum groupinstall "Development tools" -y
  EOC
  not_if "yum grouplist installed | grep 'Development tools'"
end

bash "yum groupinstall Development Libraries" do
  user "root"
  group "root"
  code <<-EOC
    yum groupinstall "Development Libraries" -y
  EOC
  not_if "yum grouplist installed | grep 'Development Libraries'"
end

%w(
  vim-minimal
  vim-common
  vim-enhanced
  git
  zlib-devel
  bzip2-devel
  openssl-devel
  ncurses-devel
  mysql-devel
  libxml2-devel
  libxslt-devel
  unixODBC-devel
  sqlite
  sqlite-devel
).each do |pkg|
  package pkg do
#    options "--enablerepo=epel"
    action :install
  end
end

remote_file "/tmp/Python-#{node[:python][:version]}.tgz" do
  source "https://www.python.org/ftp/python/#{node[:python][:version]}/Python-#{node[:python][:version]}.tgz"
#  checksum node[:python][:checksum]
  notifies :run, "bash[install_python]", :immediately
  not_if do ::File.exists?('/usr/local/bin/python2.7') end
end

bash "install_python" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    tar -zxf Python-#{node[:python][:version]}.tgz
    (cd Python-#{node[:python][:version]}/ && ./configure && make && make install)
  EOH
  action :nothing
  not_if do ::File.exists?('/usr/local/bin/python2.7') end
end

include_recipe 'python'

python_virtualenv "#{node[:python][:virtualenv]}" do
  action :create
  interpreter 'python2.7'
end

%w(
  django
  Pillow
).each do |pip_pkg|
  python_pip pip_pkg do
    action :install
    virtualenv node['python']['virtualenv']
  end
end

user 'aredmond' do
  comment "Main user"
  home "/home/aredmond"
  shell "/bin/bash"
  password '$1$I6iE/so6$qXXyCccHcw7eM0jjN00fe/'
  action :create
end
