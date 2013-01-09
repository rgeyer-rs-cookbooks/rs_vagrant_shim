class Chef
  class Provider
    class RightLinkTag < Chef::Provider
      @@persist_path = "/vagrant/rs_vagrant_shim/"
      @@persist_file = ::File.join(@@persist_path, "persist.js")

      def load_current_resource
        true
      end

      def action_publish
        # TODO: Write to a json file shared between the vagrant instance and the vagrant host
        persist_file do |json|
          json["tags"] = [] unless json.key?("tags")
          json["tags"] << @new_resource.name unless json["tags"].include? @new_resource.name
        end
        true
      end

      def action_remove
        # TODO: Write to a json file shared between the vagrant instance and the vagrant host
        persist_file do |json|
          json["tags"].delete(@new_resource.name)
        end
        true
      end

      def action_load
        # TODO: Write to a json file shared between the vagrant instance and the vagrant host
        persist_file do |json|
          node[:right_link_tags] = json["tags"]
        end
        true
      end

      def persist_file
        ::FileUtils.mkdir @@persist_path unless ::File.directory? @@persist_path
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

Chef::Platform.platforms[:default].merge!(:right_link_tag => Chef::Provider::RightLinkTag)