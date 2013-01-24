# Copyright 2013, Ryan J. Geyer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

action :dehydrate do
  node_path = ::File.join("/vagrant/", node['rs_vagrant_shim']['shim_dir'])
  node_file = ::File.join(node_path, "node.js")
  ::File.open(node_file, "w") do |file|
    file.write(JSON.pretty_generate(node))
  end
end