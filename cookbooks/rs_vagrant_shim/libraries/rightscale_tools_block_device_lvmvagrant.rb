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
      module Backup
        class VagrantFogLocalAdapter < Backup
          def initialize(cloud, mount_point, nickname, options)
            super(cloud, mount_point, nickname, options)

            local_root = "/vagrant/block_device"

            FileUtils.mkdir_p(local_root) unless ::File.exist?(local_root)

            @container = options[:primary_storage_container] || nickname

            primary_options = options.merge({
              :storage_cloud => :local,
              :storage_key => "key",
              :storage_secret => "secret",
              :storage_container => @container,
              :local_root => local_root
            })
            @ros = RightScale::Tools::ROS::Local.new("key", "secret", primary_options)
          end

          # Effectively copy/pasted from the when "put_directory" section of
          # ros_util
          def backup(lineage, options={})
            @ros.create_container_if_not_exists(@container)
            # Build the file list
            file_list = '/tmp/backup_file_list'
            source = @mount_point.chomp '/'
            File.open(file_list, File::WRONLY | File::TRUNC | File::CREAT, 0660) do |file|
              Dir.glob(File.join(source, '**', '*'), File::FNM_DOTMATCH) do |filename|
                filename = filename[source.size + 1 .. -1]
                file.puts filename unless filename =~ /^\.{1,2}$/
              end
            end

            # Setup tar command
            cmd = ['tar', '--gzip', '--create', '--directory', source, '--files-from', file_list].join ' '

            # Build the filename with date and compress suffix
            extension = 'tgz'
            filename = "#{lineage}-#{Time.now.strftime('%Y%m%d/%H%M%S')}.#{extension}"

            data_read, data_write = IO.pipe
            child = Process.detach(pid = Process.fork do
              begin
                data_read.close
                STDOUT.reopen data_write
                Process.exec cmd
              rescue Exception => e
                STDERR.puts "Error executing #{cmd} #{$$}: #{e}"
                Process.exit! 2
              end
            end)

            begin
              data_write.close
              @ros.put_object(@container, filename, data_read)
              data_read.close
            rescue Exception
              begin
                Process.kill(9, pid) if child.alive?
              rescue Exception => e
                STDERR.puts "Error killing #{pid}: #{e}"
              end
              raise
            ensure
              status = child.value
            end
            if status
              raise "Error executing '#{cmd}': #{status.exitstatus}" unless status.exitstatus == 0
            else
              puts "Somehow unable to get status from fork: #{child.inspect}, oh well."
            end
            true
          end

          def restore(lineage, options={})
            filename = @ros.get_latest_object_name(@container, lineage)
            puts "ros_util: Found latest object: #{filename}"
            case filename
            when /^(.+)\.tar$/
              puts 'Reading tar file'
              cmd = ['tar', '--extract', '--directory', @mount_point].join ' '
            when /^(.+)\.tgz$/
              puts 'Reading gzip tar (tgz) file'
              cmd = ['tar', '--gzip', '--extract', '--directory', @mount_point].join ' '
            else
              raise "File extenstion is not tar or tgz: #{filename}"
            end

            data_read, data_write = IO.pipe
            child = Process.detach(pid = Process.fork do
              begin
                data_write.close
                STDIN.reopen data_read
                Process.exec cmd
              rescue Exception => e
                STDERR.puts "Error executing #{cmd} #{$$}: #{e}"
                Process.exit! 2
              end
            end)

            begin
              data_read.close
              @ros.get_object(@container, filename, data_write)
              data_write.close
            rescue Exception
              begin
                Process.kill(9, pid) if child.alive?
              rescue Exception => e
                STDERR.puts "Error killing #{pid}: #{e}"
              end
              raise
            ensure
              status = child.value
            end
            if status
              raise "Error executing '#{cmd}': #{status.exitstatus}" unless status.exitstatus == 0
            else
              puts "Somehow unable to get status from fork: #{child.inspect}, oh well."
            end
            true
          end
        end
      end
    end
  end

  module RightScale
    module Tools
      module BlockDevice
        class LVMVagrant < LVM
          register :lvm, :vagrant

          def initialize(cloud, mount_point, nickname, options)
            super(cloud, mount_point, nickname, options)

            primary_options = options.merge({
              :endpoint => options[:primary_endpoint],
              :storage_cloud => cloud,
              :storage_key => options[:primary_storage_key],
              :storage_secret => options[:primary_storage_secret],
              :storage_container => options[:primary_storage_container] || nickname
            })
            @backup[:primary] = RightScale::Tools::Backup::VagrantFogLocalAdapter.new(
              :local,
              @snapshot_mount_point, @nickname,
              primary_options
            )
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

          def reset
            devices = @platform.get_devices_for_volume(@device)
            reset_devices(devices)
            devices.each {|device| @platform.destroy_partition(device)}
          end

          protected

          def get_data_device
            "/dev/sdb"
          end

          def on_create_error(e)
            raise "Unable to get data drive information. #{e.message}"
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