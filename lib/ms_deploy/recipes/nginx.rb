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
        protocol = fetch(:protocol, nil).to_s
        template_path = File.expand_path('../../templates/vhost.erb', __FILE__)
        vars = {
            'application'=> application,
            'project_root' => deploy_to + '/current',
            'domain' => vhost_domain, 'stage' => stage,
            'auth_basic_title' => fetch(:auth_basic_title, nil),
            'auth_basic_password_file' => fetch(:auth_basic_password_file, nil),
            'protocol' => 'http',
            'nginx_cert_dir' => fetch(:nginx_cert_dir, '/etc/nginx/cert'),
            'with_upstream_server' => true,
            'with_file_expire_max' => fetch(:with_file_expire_max, true),
            'optional_http_content' => fetch(:optional_nginx_server_http_content, ''),
            'optional_https_content' => fetch(:optional_nginx_server_https_content, ''),
            'cert_type' => fetch(:cert_type, 'pem'),
            'key_type' => fetch(:cert_type, 'key')
        }

        if protocol.nil? or protocol == 'http' or protocol == 'both'
          config_path = "#{shared_path}/config/#{application}_vhost.conf"

          put(render_erb_template(template_path, vars), config_path)
          sudo "rm -f /etc/nginx/sites-enabled/#{application}_#{stage}.conf"
          sudo "ln -s #{config_path} /etc/nginx/sites-enabled/#{application}_#{stage}.conf"
        end
        if protocol == 'https' or protocol == 'both'
          vars.merge!({'protocol' => 'https'})

          config_path = "#{shared_path}/config/#{application}_ssl_vhost.conf"

          put(render_erb_template(template_path, vars), config_path)
          sudo "rm -f /etc/nginx/sites-enabled/#{application}_#{stage}_ssl.conf"
          sudo "ln -s #{config_path} /etc/nginx/sites-enabled/#{application}_#{stage}_ssl.conf"
        end
      end

      task :uninstall  do
        protocol = fetch(:protocol, nil)

        if protocol.blank? or protocol == 'http' or protocol == 'both'
          sudo "rm -f /etc/nginx/sites-enabled/#{application}_#{stage}.conf"
        elsif protocol == 'https' or protocol == 'both'
          sudo "rm -f /etc/nginx/sites-enabled/#{application}_#{stage}_ssl.conf"
        end
      end
    end
  end

  after :"deploy:setup", :"service:nginx:install";

end
