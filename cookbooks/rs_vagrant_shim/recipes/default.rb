#
# Cookbook Name:: rs_vagrant_shim
# Recipe:: default
#
# Copyright (c) 2013 Ryan J. Geyer
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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