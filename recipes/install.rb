
user node.hopslog.user do
  home "/home/#{node.hopslog.user}"
  action :create
  system true
  shell "/bin/bash"
  manage_home true
  not_if "getent passwd #{node.hopslog.user}"
end

group node.hopslog.group do
  action :modify
  members ["#{node.hopslog.user}"]
  append true
end


include_recipe "java"

package_url = "#{node.logstash.url}"
base_package_filename = File.basename(package_url)
cached_package_filename = "/tmp/#{base_package_filename}"

remote_file cached_package_filename do
  source package_url
  owner "root"
  mode "0644"
  action :create_if_missing
end


logstash_downloaded = "#{node.logstash.home}/.logstash.extracted_#{node.logstash.version}"
# Extract logstash
bash 'extract_logstash' do
        user "root"
        code <<-EOH
                tar -xf #{cached_package_filename} -C #{node.hopslog.dir}
                chown -R #{node.hopslog.user}:#{node.hopslog.group} #{node.logstash.home}
                cd #{node.logstash.home}
                touch #{logstash_downloaded}
                chown #{node.hopslog.user} #{logstash_downloaded}
        EOH
     not_if { ::File.exists?( logstash_downloaded ) }
end

file node.logstash.base_dir do
  action :delete
  force_unlink true
end

link node.logstash.base_dir do
  owner node.hopslog.user
  group node.hopslog.group
  to node.logstash.home
end


directory "#{node.logstash.base_dir}/log" do
  owner node.hopslog.user
  group node.hopslog.group
  mode "750"
  action :create
end


directory "#{node.logstash.base_dir}/conf" do
  owner node.hopslog.user
  group node.hopslog.group
  mode "750"
  action :create
end














package_url = "#{node.kibana.url}"
base_package_filename = File.basename(package_url)
cached_package_filename = "/tmp/#{base_package_filename}"

remote_file cached_package_filename do
  source package_url
  owner "root"
  mode "0644"
  action :create_if_missing
end


kibana_downloaded = "#{node.kibana.home}/.kibana.extracted_#{node.kibana.version}"
# Extract kibana
bash 'extract_kibana' do
        user "root"
        code <<-EOH
                tar -xf #{cached_package_filename} -C #{node.hopslog.dir}
                chown -R #{node.hopslog.user}:#{node.hopslog.group} #{node.kibana.home}
                cd #{node.kibana.home}
                touch #{kibana_downloaded}
                chown #{node.hopslog.user} #{kibana_downloaded}
        EOH
     not_if { ::File.exists?( kibana_downloaded ) }
end

file node.kibana.base_dir do
  action :delete
  force_unlink true
end

link node.kibana.base_dir do
  owner node.hopslog.user
  group node.hopslog.group
  to node.kibana.home
end


directory "#{node.kibana.base_dir}/log" do
  owner node.hopslog.user
  group node.hopslog.group
  mode "750"
  action :create
end


directory "#{node.kibana.base_dir}/conf" do
  owner node.hopslog.user
  group node.hopslog.group
  mode "750"
  action :create
end
