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

    desc "init", "Creates a new rs_vagrant_shim project, including all the goodies you need like a Berksfile, Vagrantfile, etc"
    option :vmnames,
           :desc => "The name of one more many VMs to add to the Vagrantfile",
           :type => :array
    def init
      vagrantfile_template = <<-EOF
require 'berkshelf/vagrant'
require 'rs_vagrant_shim'

Vagrant::Config.run do |config|
  <% boxes.each do |vmname| %>
  config.vm.define :<%= vmname %> do |<%= vmname %>_config|
    <%= vmname %>_config.berkshelf.berksfile_path = "Berksfile"

    <%= vmname %>_config.vm.host_name = "<%= vmname %>"

    <%= vmname %>_config.vm.box = "ri_centos6.3_berks"
    <%= vmname %>_config.vm.box_url = "https://s3.amazonaws.com/rgeyer/pub/ri_centos6.3_v5.8.8_vagrant.box"

    # TODO: Increment this for each VM in a multi VM Vagrant file
    <%= vmname %>_config.vm.network :hostonly, "33.33.33.10"

    <%= vmname %>_config.ssh.max_tries = 40
    <%= vmname %>_config.ssh.timeout   = 120

    <%= vmname %>_config.vm.provision Vagrant::RsVagrantShim::Provisioners::RsVagrantShim do |chef|
      chef.run_list_dir = "runlists/<%= vmname %>"
      chef.shim_dir = "rs_vagrant_shim/<%= vmname %>"
    end
  end
  <% end %>
end
      EOF

      vagrantfile_erb = ERB.new(vagrantfile_template)
      boxes = ["default"]
      boxes = options[:vmname] if options[:vmname] && !options[:vmname].empty?
      File.open("Vagrantfile", "w") do |file|
        file.write(vagrantfile_erb.result(binding))
      end

      boxes.each do |box|
        FileUtils.mkdir_p "runlists/#{box}"
        FileUtils.mkdir_p "rs_vagrant_shim/#{box}"
      end
    end
  end
end