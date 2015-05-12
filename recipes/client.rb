#
# Cookbook Name:: munin
# Recipe:: client
#
# Copyright 2010, Opscode, Inc.
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
#

#munin_servers = search(:node, "role:#{node['munin']['server_role']} AND chef_environment:#{node.chef_environment}")
munin_servers = [node]

package "munin-node"
package "munin-plugins-extra"

service "munin-node" do
  if node[:lsb][:release].to_f >= 14.04
    provider Chef::Provider::Service::Upstart
  end
  action [:enable, :start]
  supports :status => true, :restart => true, :reload => true
end

template "#{node['munin']['basedir']}/munin-node.conf" do
  source "munin-node.conf.erb"
  mode 0644
  variables :munin_servers => munin_servers
  notifies :restart, resources(:service => "munin-node")
end

# case node[:platform]
# when "arch"
  execute "munin-node-configure --shell | sh" do
    not_if { Dir.entries(node['munin']['plugins']).length > 2 }
    notifies :restart, "service[munin-node]"
  end
# end
