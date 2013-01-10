Description
===========

A cookbook which hopes to allow vagrant interoperability with RightScale Chef cookbooks, including support for the RightScale only functionality like remote_recipe, server_collection, and right_link_tag.

The persistent file is stored in /vagrant/rs_vagrant_shim/#{config.vm.hostname}, so in a multi VM vagrant environment, make sure that the hostnames are unique!

Requirements
============

Attributes
==========

Features
========
* Writes collectd rrd data to /var/lib/collectd (or OS specific directory) so that you can verify custom monitoring configurations

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


Stream of Consciousness
=======================

* rs_vagrant_shim/<hostname>/persist.js
  * Only the vagrant boxes can read and write to persist.js
  * The host can read, usually only for the purposes of fetching tags
* rs_vagrant_shim/<hostname>/dispatch/*.js
  * files which contain both a runlist and attributes
  * written once by the vagrant boxes
  * read, acted upon, and destroyed by the host
* host daemon
  * watches rs_vagrant_shim/**/dispatch/ for new *.js files
  * upon finding one, runs `bundle exec vagrant provision <boxname>` for each box with the target tag specified in the dispatch *.js file
* vagrantfile
  * A library will be added to the vagrant file (I.E. require 'somelib') which will interrogate the dispatch directory and replace chef.json and chef.run_list with the correct stuff, or default to the boot runlist

blueprint_root/
  runlists/
    default|boot.rb
    operational_recipe_name.rb
  rs_vagrant_shim/
    hostname1/
      persist.js
      dispatch/
    hostname2/
      persist.js
      dispatch/

The following should result in running the operational recipe defined in runlists/operational_recipe_name.rb, and then the dispatch file should be destroyed
  cp runlists/operational_recipe_name.rb rs_vagrant_shim/hostname1/dispatch/foo.rb
  bundle exec vagrant provision hostname1