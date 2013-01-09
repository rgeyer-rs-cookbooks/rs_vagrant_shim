Description
===========

A cookbook which hopes to allow vagrant interoperability with RightScale Chef cookbooks, including support for the RightScale only functionality like remote_recipe, server_collection, and right_link_tag.

Requirements
============

Attributes
==========

Usage
=====

Add the default recipe as the first recipe in your runlist for vagrant.

A bare minimum sample Vagrantfile
  require 'berkshelf/vagrant'

  Vagrant::Config.run do |config|
    config.vm.host_name = "rs_vagrant_shim"

    config.vm.box = "Berkshelf-CentOS-6.3-x86_64-minimal"
    config.vm.box_url = "https://dl.dropbox.com/u/31081437/Berkshelf-CentOS-6.3-x86_64-minimal.box"

    config.vm.network :hostonly, "33.33.33.10"

    config.ssh.max_tries = 40
    config.ssh.timeout   = 120

    config.vm.provision :chef_solo do |chef|
      chef.json = {
        # A few things that need to be set before any recipe or
        # default attributes file can set them
        :cloud => { :provider => "vagrant" },
        :rightscale => { :instance_uuid => "UUID" }
      }

      chef.run_list = [
        "recipe[rs_vagrant_shim]"
      ]
    end
  end

sys_firewall mucks up something which makes it impossible to ssh into the vagrant box after startup.  I've tried enabling port 2222 but that does not seem to help.  So for now node['sys_firewall']['enabled'] gets hardcoded to 'disabled'

TODO
====

* Implement
  * remote_recipe
  * server_collection
* Allow the use of
  * block_device::*, but particularly block_device::setup_ephemeral
  * sys::setup_swap