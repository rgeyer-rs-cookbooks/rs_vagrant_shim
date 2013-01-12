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
      persist_path = ::File.join("/vagrant/", node['rs_vagrant_shim']['shim_dir'])
      path_for_glob = ::File.expand_path(::File.join(persist_path, '..') + '/*')
      Dir.glob(path_for_glob).select{|dir| dir != persist_path}
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
  end
end