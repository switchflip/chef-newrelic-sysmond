#
# Cookbook Name:: newrelic-sysmond
# Recipe:: default
#
# Copyright 2011-2014, Phil Cohen
#
# Modifications added by Thomas Berry at TouchBistro in Toronto, ON

current_platform = node["platform"]

if node["new_relic"]["license_key"].empty?
  warning = <<-EOM
The `newrelic-sysmond` recipe was included, but a licence key was not provided.
Please set `node["new_relic"]["license_key"]` to avoid this warning.
EOM

  log warning do
    level :warn
  end

  return
end

# apt repository
apt_repository "newrelic" do
  uri node["new_relic"]["apt_uri"]
  components %w[newrelic non-free]
  key node["new_relic"]["apt_key"]
  keyserver node["new_relic"]["keyserver"]
  only_if { platform_family?("debian") }
end

# yum repository
yum_repository "newrelic" do
  description "New Relic"
  baseurl node["new_relic"]["yum_baseurl"]
  gpgcheck false
  only_if { platform_family?("rhel") }
end

package "newrelic-sysmond"

template "/etc/newrelic/nrsysmond.cfg" do
  source "nrsysmond.cfg.erb"
  owner "root"
  group "newrelic"
  mode "0640"
end

if current_platform == "ubuntu"  
  file "/etc/init.d/newrelic-sysmond" do
    action :delete
  end
  template "etc/init/newrelic-sysmond.conf" do
    source "newrelic-sysmond.conf.erb"
    owner "root"
    group "root"
    action :create
  end
end

# We get this far...
# problems
# .conf file not working

# Error executing action `start` on resource 'service[newrelic-sysmond]'

service "newrelic-sysmond" do
  provider Chef::Provider::Service::Upstart if current_platform == "ubuntu"
  supports :status => true, :start => true, :stop => true, :restart => true
  action [:enable, :start]
end