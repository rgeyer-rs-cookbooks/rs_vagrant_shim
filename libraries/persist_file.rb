module RsVagrantShim
  class PersistFile
    @@persist_path = "/vagrant/rs_vagrant_shim/#{`hostname`.strip}/"
    @@persist_file = ::File.join(@@persist_path, "persist.js")

    def self.get_exclusive_access
      wtf = ::File.join(@@persist_path, "persist.lock")
      ::Chef::Log.info("Persist path #{@@persist_path} -- persist file #{@@persist_file} -- lockfile #{wtf}")
      ::FileUtils.mkdir_p @@persist_path unless ::File.directory? @@persist_path
      begin
        json = {}
        json = JSON.parse(::File.read(@@persist_file)) if ::File.exist? @@persist_file
        yield json
        ::File.open(@@persist_file, 'w') do |file|
          file.write(JSON.pretty_generate(json))
        end
      end
    end
  end
end