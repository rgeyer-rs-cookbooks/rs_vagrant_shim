class Chef
  class Provider
    class RightLinkTag < Chef::Provider

      def load_current_resource
        true
      end

      def action_publish
        RsVagrantShim::PersistFile.get_exclusive_access do |json|
          json["tags"] = [] unless json.key?("tags")
          json["tags"] << @new_resource.name unless json["tags"].include? @new_resource.name
        end
        true
      end

      def action_remove
        RsVagrantShim::PersistFile.get_exclusive_access do |json|
          json["tags"].delete(@new_resource.name)
        end
        true
      end

      def action_load
        RsVagrantShim::PersistFile.get_exclusive_access do |json|
          node[:right_link_tags] = json["tags"]
        end
        true
      end

    end
  end
end

Chef::Platform.platforms[:default].merge!(:right_link_tag => Chef::Provider::RightLinkTag)