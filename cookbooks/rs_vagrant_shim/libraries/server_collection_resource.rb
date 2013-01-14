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

    # Servers with associated tags
    #
    class ServerCollection < Chef::Resource
      def initialize(name, run_context=nil)
        super(name, run_context)
        @resource_name = :server_collection
        @action = :load
        @allowed_actions.push(:load)
        @timeout = 120
      end

      def agent_ids(arg=nil)
        converted_arg = arg.is_a?(String) ? [ arg ] : arg
        set_or_return(
          :agent_ids,
          converted_arg,
          :kind_of => [ Array ]
        )
      end

      def tags(arg=nil)
        converted_arg = arg.is_a?(String) ? [ arg ] : arg
        set_or_return(
          :tags,
          converted_arg,
          :kind_of => [ Array ]
        )
      end

    end

  end

end