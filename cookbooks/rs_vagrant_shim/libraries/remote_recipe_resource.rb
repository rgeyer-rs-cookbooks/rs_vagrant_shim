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
          arg || {},
          :kind_of => [ Hash ]
        )
      end

      def recipients(arg=nil)
        converted_arg = arg.is_a?(String) ? [ arg ] : arg
        set_or_return(
          :recipients,
          converted_arg,
          :kind_of => [ Array ]
        )
      end

      def recipients_tags(arg=nil)
        converted_arg = arg.is_a?(String) ? [ arg ] : arg
        set_or_return(
          :recipients_tags,
          converted_arg,
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