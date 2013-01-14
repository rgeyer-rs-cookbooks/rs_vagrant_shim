#
# Cookbook Name:: rs_vagrant_shim
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

default[:cloud][:provider] = 'vagrant'
default[:cloud][:private_ips] = []
default[:cloud][:public_ips] = []

default[:rightscale][:instance_uuid] = "UUID"
default[:rightscale][:servers][:sketchy][:hostname] = 'localhost'

# If it isn't set, set it
default[:sys_firewall][:enabled] = 'disabled'
# If it is set, overwrite it
node[:sys_firewall][:enabled] = 'disabled'

default[:sys][:swap_size] = "0.5"
default[:sys][:swap_file] = "/mnt/ephemeral/swapfile"

node['network']['interfaces'].each do |iface|
  iface[1]['addresses'].each do |addr|
    ip = addr[0]
    details = addr[1]
    if details['family'] == 'inet'
      case ip
        when /^10|172|192\./
          node[:cloud][:private_ips] << ip
        when "127.0.0.1"
          # Intentionally don't do anything
        else
          node['cloud']['public_ips'] << ip
      end
    end
  end
end