
#
# sudoers:
# %deploy ALL=(ALL) NOPASSWD: /usr/local/bin/bluepill, /sbin/start my_app_bluepill , /sbin/stop my_app_bluepill
# sudo chown root:root deploy_conf
# sudo chmod 0440 deploy_conf
# => /etc/sudoers.d
#
Capistrano::Configuration.instance.load do

  namespace :deploy do

    task :start, :roles => :app, :except => { :no_release => true } do
      sudo 'start bluepill_conf'
    end

    task :stop, :roles => :app, :except => { :no_release => true } do
      sudo "bluepill stop"
      sudo "stop bluepill_conf"
    end

    task :restart, :roles => :app, :except => { :no_release => true } do
      sudo "bluepill restart unicorn"
    end

    #desc "Restart Resque Workers"
    #task :restart_workers do
    #  sudo "bluepill stop resque"
    #  sudo "bluepill start resque"
    #end
    #
    #desc "Start Resque Workers"
    #task :start_workers do
    #  sudo "bluepill start resque"
    #end
    #
    #desc "Stop Resque Workers"
    #task :stop_workers do
    #  sudo "bluepill stop resque"
    #end

  end

  namespace :bluepill do
    desc "Prints bluepills monitored processes statuses"
    task :status, :roles => [:app] do
      sudo "bluepill status"
    end

    desc "Setup blupill config"
    task :setup, :roles => [:app] do
    setup_init
    setup_config
    end

    task :setup_init do
      template_path = File.expand_path('../../templates/bluepill/init.erb', __FILE__)
      vars = {
          'application' => application,
          'config_path' => fetch(:bluepill_config_path, "#{shared_path}/config/bluepill_config.pill")
      }

      config_path = "#{shared_path}/config/bluepill_init.conf"

      put(render_erb_template(template_path, vars), config_path)
      sudo "rm -f /etc/init/bluepill_#{application}_#{stage}.conf"
      sudo "ln -s #{config_path} /etc/init/bluepill_#{application}_#{stage}.conf"
    end

    task :setup_config do
      template_path = File.expand_path('../../templates/bluepill/default_config.rb.erb', __FILE__)
      log_file = "#{latest_release}/log/bluepill.log"
      unicorn_config_path = "#{shared_path}/config/unicorn/#{stage}.rb"
      vars = {
          'application' => application,
          'stage' => stage,
          'log_file' => log_file,
          'unicorn_config_path' => unicorn_config_path
      }

      config_path = fetch(:bluepill_config_path, "#{shared_path}/config/bluepill_config.pill")
      put(render_erb_template(template_path, vars), config_path)

    end
  end

  #after "deploy:restart", "deploy:restart_workers"
  after "deploy:setup", "bluepill:setup"

end
