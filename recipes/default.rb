#
# Cookbook Name:: rs_vagrant_shim
# Recipe:: default
#
# Copyright 2013, Ryan J. Geyer
#
# All rights reserved - Do Not Redistribute
#

# TODO: Set these node attributes using ohai and other goodies
#:cloud => {
# :private_ips => ["127.0.0.1"],
# :public_ips => ["33.33.33.11"]
#},
#:rightscale => {
# :instance_uuid => "auuid",
# :collectd_packages_version => "latest",
# :servers => {
#   :sketchy => {
#     :hostname => "foo.bar.baz"
#   }
# }
#}

chef_gem "chef-rewind"
require 'chef/rewind'

# Used by RsVagrantShim::PersistFile
chef_gem "lockfile"
require 'lockfile'

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