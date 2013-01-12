# Can't be sure that Chef will load the stuff in the libs dir in a consistent order
require ::File.expand_path(::File.join(::File.dirname(__FILE__), "helper"))

class Chef
  class Provider
    class RightLinkTag < Chef::Provider

      include ::RsVagrantShim::Helper

      def load_current_resource
        true
      end

      def action_publish
        get_exclusive_access(node) do |json|
          json["tags"] = [] unless json.key?("tags")
          json["tags"] << @new_resource.name unless json["tags"].include? @new_resource.name
        end
        true
      end

      def action_remove
        get_exclusive_access(node) do |json|
          json["tags"].delete(@new_resource.name)
        end
        true
      end

      def action_load
        get_exclusive_access(node) do |json|
          node[:right_link_tags] = json["tags"]
        end
        true
      end

    end
  end
end

Chef::Platform.platforms[:default].merge!(:right_link_tag => Chef::Provider::RightLinkTag)