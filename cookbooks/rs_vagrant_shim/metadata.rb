maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "All rights reserved"
description      "Installs/Configures rs_vagrant_shim"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

supports "centos"

depends "yum", ">= 2.0.6"
depends "cron", ">= 1.2.2"
depends "rightscale", ">= 13.2"
depends "sys_firewall", ">= 13.2"