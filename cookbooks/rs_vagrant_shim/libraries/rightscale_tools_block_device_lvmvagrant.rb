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

begin
  require 'rightscale_tools'

  module RightScale
    module Tools
      module BlockDevice
        class LVMVagrant < LVM
          register :lvm, :vagrant

          def initialize(cloud, mount_point, nickname, options)
            super(cloud, mount_point, nickname, options)

            primary_options = options.merge({
              :storage_cloud => :local,
              :storage_key => "key",
              :storage_secret => "secret",
              :storage_container => "foo",
              :local_root => "/vagrant/block_device"
            })

            @backup[:primary] = RightScale::Tools::Backup.factory(
              :ros,
              :local,
              @snapshot_mount_point,
              @nickname,
              primary_options)
          end

          def create(options = {})
            data_device = get_data_device
            info = {}
            begin
              @platform.make_device_label(data_device, "msdos")
              info = @platform.get_device_partition_info(data_device)
            rescue Exception => e
              on_create_error(e)
            end
            @logger.info "partition info for #{data_device}: #{info.inspect}"
            device = @platform.create_partition(data_device, 512, info[:size]-1)
            initialize_stripe([device])
          end

          protected

          def get_data_device
            "/dev/sdb"
          end

          def on_create_error(e)
            raise "Unable to get data drive information. Please be sure you are using a SoftLayer 'Storage' image. #{e.message}"
          end

          def create_before_restore?(level)
            true
          end
        end
      end
    end
  end
rescue LoadError
  # Should be able to survive this initial failure to load since
  # most things that would require this monkey patch won't occur
  # until a subsequent provision, simulating an operational recipe
end