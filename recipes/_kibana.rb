my_private_ip = my_private_ip()


elastic = private_recipe_ip("elastic", "default") + ":#{node.elastic.port}"



bash 'add_elastic_index_for_kibana' do
        user "root"
        code <<-EOH
            set -e
            curl -XPUT "#{elastic}/customer?pretty"
        EOH
#     not_if { }
end




file "#{node.kibana.base_dir}/conf/kibana-site.xml" do
  action :delete
end


template"#{node.kibana.base_dir}/config/kibana.yml" do
  source "kibana.yml.erb"
  owner node.hopslog.user
  group node.hopslog.group
  mode 0655
  variables({ 
     :my_ip => my_private_ip,
     :elastic_addr => elastic
           })
end


template"#{node.kibana.base_dir}/bin/start-kibana.sh" do
  source "start-kibana.sh.erb"
  owner node.hopslog.user
  group node.hopslog.group
  mode 0750
end

template"#{node.kibana.base_dir}/bin/stop-kibana.sh" do
  source "stop-kibana.sh.erb"
  owner node.hopslog.user
  group node.hopslog.group
  mode 0750
end


case node.platform
when "ubuntu"
 if node.platform_version.to_f <= 14.04
   node.override.kibana.systemd = "false"
 end
end


service_name="kibana"

if node.kibana.systemd == "true"

  service service_name do
    provider Chef::Provider::Service::Systemd
    supports :restart => true, :stop => true, :start => true, :status => true
    action :nothing
  end

  case node.platform_family
  when "rhel"
    systemd_script = "/usr/lib/systemd/system/#{service_name}.service" 
  when "debian"
    systemd_script = "/lib/systemd/system/#{service_name}.service"
  end

  template systemd_script do
    source "#{service_name}.service.erb"
    owner "root"
    group "root"
    mode 0754
    notifies :enable, resources(:service => service_name)
    notifies :start, resources(:service => service_name), :immediately
  end

  kagent_config "reload_kibana_daemon" do
    action :systemd_reload
  end  

else #sysv

  service service_name do
    provider Chef::Provider::Service::Init::Debian
    supports :restart => true, :stop => true, :start => true, :status => true
    action :nothing
  end

  template "/etc/init.d/#{service_name}" do
    source "#{service_name}.erb"
    owner node.hopslog.user
    group node.hopslog.group
    mode 0754
    notifies :enable, resources(:service => service_name)
    notifies :restart, resources(:service => service_name), :immediately
  end

end


if node.kagent.enabled == "true" 
   kagent_config "kibana" do
     service "kibana"
     log_file "#{node.kibana.base_dir}/kibana.log"
   end
end



