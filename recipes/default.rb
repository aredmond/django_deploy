#
# Cookbook Name:: django_deploy
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'build-essential::default'
include_recipe 'python'

python_virtualenv '/usr/local/share/.virtualenvs' do
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
