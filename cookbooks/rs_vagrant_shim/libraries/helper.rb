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
  module Helper

    # Accesses the persist.json file in the shim directory of "this" VM.
    #
    # Expects to be passed a block which will have a hash yielded to it.  That hash
    # will represent the current contents of the persist.json file.  When the block
    # returns, any changes to the hash will be written back to the persist.json file
    def read_write_my_persist_file(node)
      persist_path = ::File.join("/vagrant/", node['rs_vagrant_shim']['shim_dir'])
      persist_file = ::File.join(persist_path, "persist.json")
      ::FileUtils.mkdir_p persist_path unless ::File.directory? persist_path
      begin
        persist_hash = read_persist_file(persist_file)
        yield persist_hash
        ::File.open(persist_file, 'w') do |file|
          file.write(JSON.pretty_generate(persist_hash))
        end
      end
    end

    # Lists all directories that are in the same directory as the shim directory
    # for "this" VM.  Excludes "this" VM
    #
    def other_vm_shim_dirs(node)
      all_vm_shim_dirs(node).select{|dir| dir != persist_path}
    end

    def all_vm_shim_dirs(node)
      persist_path = ::File.join("/vagrant/", node['rs_vagrant_shim']['shim_dir'])
      path_for_glob = ::File.expand_path(::File.join(persist_path, '..') + '/*')
      Dir.glob(path_for_glob)
    end

    # Reads the contents of a persist.json file specified by it's full filename
    #
    # @return A hash representing the contents of the file, or an empty hash if the file does not exist
    def read_persist_file(filename)
      if ::File.exist? filename
        JSON.parse(::File.read(filename))
      else
        {}
      end
    end

    def uuid_from_shim_dir(shim_dir)
      matches = /\/([a-zA-z_0-9]+)$/.match(shim_dir)
      if matches && matches.length > 1
        matches[1]
      else
        nil
      end
    end
  end
end