class Chef
  class Resource
    class RemoteRecipe < Chef::Resource
      def initialize(name, run_context=nil)
        super(name, run_context)
        @resource_name = :remote_recipe
        @scope = :all
        @action = :run
        @allowed_actions.push(:run)
      end

      def recipe(arg=nil)
        set_or_return(
          :recipe,
          arg,
          :kind_of => [ String ]
        )
      end

      def attributes(arg=nil)
        set_or_return(
          :attributes,
          arg,
          :kind_of => [ Hash ]
        )
      end

      def recipients(arg=nil)
        converted_arg = arg.is_a?(String) ? [ arg ] : arg
        set_or_return(
          :recipients,
          arg,
          :kind_of => [ Array ]
        )
      end

      def recipients_tags(arg=nil)
        converted_arg = arg.is_a?(String) ? [ arg ] : arg
        set_or_return(
          :recipients_tags,
          arg,
          :kind_of => [ Array ]
        )
      end

      def scope(arg=nil)
        set_or_return(
          :scope,
          arg,
          :equal_to => [ :single, :all ]
        )
      end
    end
  end
end