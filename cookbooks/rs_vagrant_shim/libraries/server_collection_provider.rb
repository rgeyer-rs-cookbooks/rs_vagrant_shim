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

# Can't be sure that Chef will load the stuff in the libs dir in a consistent order
require ::File.expand_path(::File.join(::File.dirname(__FILE__), "helper"))

class Chef
  class Provider
    class ServerCollection < Chef::Provider

      include ::RsVagrantShim::Helper

      def load_current_resource
        true
      end

      def action_load
        tags = @new_resource.tags
        node[:server_collection] ||= {}
        node[:server_collection][@new_resource.name] = {}
        all_vm_shim_dirs(node).each do |shim_dir|
          persist_file = ::File.join(shim_dir, "persist.json")
          persist_hash = read_persist_file(persist_file)
          if persist_hash.key?("tags")
            persist_hash["tags"].each do |vm_tag|
              tags.each do |tag_query|
                subd_tag_query = tag_query.gsub('*', '')
                if vm_tag.start_with?(subd_tag_query)
                  uuid = uuid_from_shim_dir(shim_dir)
                  node[:server_collection][@new_resource.name][uuid] = persist_hash["tags"] if uuid
                  next
                end
              end
            end
          end
        end
        true
      end

    end
  end
end

Chef::Platform.platforms[:default].merge!(:server_collection => Chef::Provider::ServerCollection)