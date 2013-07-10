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

module VagrantPlugins
  module RsVagrantShim
    class Provisioner < ::VagrantPlugins::Chef::Provisioner::ChefSolo

      def self.config_class
        Config
      end

      def provision!
        super

        # Delete the one-time runlist file
        FileUtils.rm @config.one_time_runlist_file if @config.one_time_runlist_file && File.exist?(@config.one_time_runlist_file)
      end

      def cleanup
        @hostname_dir = File.join(Dir.pwd, 'rs_vagrant_shim', @env[:vm].config.vm.host_name)
        FileUtils.rm_rf @hostname_dir if File.directory? @hostname_dir
        super
      end
    end
  end
end