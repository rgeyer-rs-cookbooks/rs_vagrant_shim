#
# Cookbook Name:: rs_vagrant_shim
# Recipe:: default
#
# Copyright 2013, Ryan J. Geyer
#
# All rights reserved - Do Not Redistribute
#

############### START COMPILE TIME EXECUTION

# Hack up some filesystem things *right now*
#d = directory "/opt/rightscale/sandbox/bin" do
#  recursive true
#  action :nothing
#end

#d.run_action(:create)

#l = link "/opt/rightscale/sandbox/bin/gem" do
#  to "/opt/chef/embedded/bin/gem"
#  action :nothing
#end

#l.run_action(:create)

# RightImage dependencies
#%w{libxml2-devel libxslt-devel}.each do |p|
#  pack = package p do
#    action :nothing
#  end
#
#  pack.run_action(:install)
#end

chef_gem "chef-rewind"
require 'chef/rewind'

############### END COMPILE TIME EXECUTION

include_recipe "cron"

if node['platform_family'] == "rhel"
  include_recipe "yum::epel"
end

package "ruby"
package "collectd-rrdtool"

# TODO: Not sure why running this in the actual rightscale::setup_monitoring does not work
# But collectd is not installed on Cent 6.3
packages = node[:rightscale][:collectd_packages]
packages.each do |p|
  package "rs_vagrant_shim install package #{p}" do
    package_name p
    action :install
  end
end

include_recipe "rightscale::setup_monitoring"

# Don't let rightscale::setup_monitoring bully us
rewind "package[collectd]" do
  only_if { false }
end

sys_firewall "2222"