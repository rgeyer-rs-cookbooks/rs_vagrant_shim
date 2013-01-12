default[:cloud][:provider] = 'vagrant'
default[:cloud][:private_ips] = []
default[:cloud][:public_ips] = []

default[:rightscale][:instance_uuid] = "UUID"
default[:rightscale][:servers][:sketchy][:hostname] = 'localhost'

# If it isn't set, set it
default[:sys_firewall][:enabled] = 'disabled'
# If it is set, overwrite it
node[:sys_firewall][:enabled] = 'disabled'

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