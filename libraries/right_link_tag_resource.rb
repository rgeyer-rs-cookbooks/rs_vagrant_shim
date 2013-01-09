class Chef
  class Resource
    class RightLinkTag < Chef::Resource
      def initialize(name, run_context=nil)
        super(name, run_context)
        @resource_name = :right_link_tag
        @action = :publish
        @allowed_actions.push(:publish, :remove, :load)
      end
    end
  end
end