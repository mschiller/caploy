require "ms_deploy/render"

Capistrano::Configuration.instance.load do

  namespace :service do
    namespace :nginx do
      desc <<-DESC
        Starts the nginx web-server.
      DESC
      task :start do
        #run "sudo god start nginx"
        run "sudo /etc/init.d/nginx start"
      end

      desc <<-DESC
        #Stops the nginx web-server.
      DESC
      task :stop do
        #run "sudo god stop nginx"
        run "sudo /etc/init.d/nginx stop"
      end

      desc <<-DESC
        Restarts the nginx web-server.
      DESC
      task :restart do
        #run "sudo god restart nginx"
        run "sudo /etc/init.d/nginx restart"
      end

      task :install  do
        template_path = File.expand_path('../../templates/vhost.erb', __FILE__)
        vars = {'application'=> application, 'project_root' => deploy_to + '/current', 'server_name' => server_name}
        config_path = "#{shared_path}/config/#{application}_vhost.conf"

        put(render_erb_template(template_path, vars), config_path)
        sudo "rm -f /etc/nginx/sites-enabled/#{application}.conf"
        sudo "ln -s #{config_path} /etc/nginx/sites-enabled/#{application}.conf"
      end

      task :uninstall  do
        sudo "rm -f /etc/nginx/sites-enabled/#{application}.conf"
      end
    end
  end

  after :"deploy:setup", :"service:nginx:install";

end
