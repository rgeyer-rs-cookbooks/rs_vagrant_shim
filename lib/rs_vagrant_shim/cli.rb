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

module RsVagrantShim
  class Cli < Thor

    desc "init PROJECTNAME", "Creates a new rs_vagrant_shim project in a directory specified by PROJECTNAME, including all the goodies you need like a Berksfile, Vagrantfile, etc"
    option :vmnames,
           :desc => "The name of one more many VMs to add to the Vagrantfile",
           :type => :array
    def init(projectname)
      if File.directory? projectname
        puts "A directory named #{projectname} already exists, please specify a different project name"
        return
      else
        FileUtils.mkdir_p projectname
      end

      vagrantfile_template = <<-EOF
require 'berkshelf/vagrant'
require 'rs_vagrant_shim'

Vagrant::Config.run do |config|
  <% idx = 0 %>
  <% boxes.each do |vmname| %>
  config.vm.define :<%= vmname %> do |<%= vmname %>_config|
    <%= vmname %>_config.berkshelf.berksfile_path = "Berksfile"

    <%= vmname %>_config.vm.host_name = "<%= vmname %>"

    <%= vmname %>_config.vm.box = "ri_centos6.3_v5.8.8"
    <%= vmname %>_config.vm.box_url = "https://s3.amazonaws.com/rgeyer/pub/ri_centos6.3_v5.8.8_vagrant.box"

    <%= vmname %>_config.vm.network :hostonly, "33.33.33.<%= 10 + idx %>"

    <%= vmname %>_config.ssh.max_tries = 40
    <%= vmname %>_config.ssh.timeout   = 120

    <%= vmname %>_config.vm.provision Vagrant::RsVagrantShim::Provisioners::RsVagrantShim do |chef|
      chef.run_list_dir = "runlists/<%= vmname %>"
      chef.shim_dir = "rs_vagrant_shim/<%= vmname %>"
    end
    <% idx += 1 %>
  end
  <% end %>
end
      EOF

      default_runlist_template = <<-EOF
{
  "cloud": { "provider": "vagrant", "public_ips": [], "private_ips": [] },
  "rightscale": { "instance_uuid": "uuid-<%= box %>" },
  "run_list": [
    "recipe[rs_vagrant_shim]"
  ]
}
      EOF

      vagrantfile_erb = ERB.new(vagrantfile_template)
      boxes = ["default"]
      boxes = options[:vmnames] if options[:vmnames] && !options[:vmnames].empty?
      File.open(File.join(projectname, "Vagrantfile"), "w") do |file|
        file.write(vagrantfile_erb.result(binding))
      end

      boxes.each do |box|
        runlist_dir = File.join(projectname, "runlists", box)
        shim_dir = File.join(projectname, "rs_vagrant_shim", box)
        FileUtils.mkdir_p runlist_dir unless File.directory? runlist_dir
        FileUtils.mkdir_p shim_dir unless File.directory? shim_dir
        default_runlist_file = File.join(runlist_dir, "default.json")
        default_runlist_erb = ERB.new(default_runlist_template)
        File.open(File.join(default_runlist_file), "w") do |file|
          file.write(default_runlist_erb.result(binding))
        end
      end

      # This is where the gemfile definition is copied from the .gemspec, probably
      # need to store these in a single file and source them from both locations
      File.open(File.join(projectname, "Gemfile"), "w") do |file|
        file.write <<-EOF
source :rubygems

# This is probably a bad idea during dev, you might wanna consider specifying
# a specific rs_vagrant_shim
gem "rs_vagrant_shim", "~> 0.0.1"

gem "berkshelf", "~> 1.1"
gem "vagrant", "~> 1.0.5"
        EOF
      end

      File.open(File.join(projectname, "Berksfile"), "w") do |file|
        file.write <<-EOF
site :opscode

cookbook "rightscale",
  git: "git://github.com/rightscale/rightscale_cookbooks.git",
  branch: "v13.2",
  rel: "cookbooks/rightscale"

cookbook "sys",
  git: "git://github.com/rightscale/rightscale_cookbooks.git",
  branch: "v13.2",
  rel: "cookbooks/sys"

cookbook "sys_firewall",
  git: "git://github.com/rightscale/rightscale_cookbooks.git",
  branch: "v13.2",
  rel: "cookbooks/sys_firewall"

group :vagrant_only do
  cookbook "rs_vagrant_shim",
    git: "https://github.com/rgeyer-rs-cookbooks/rs_vagrant_shim.git",
    rel: "cookbooks/rs_vagrant_shim"
end
        EOF
      end
    end
  end
end