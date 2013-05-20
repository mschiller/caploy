require 'capistrano'
require 'capistrano/version'

module Unicorn
  class CapistranoIntegration
    def self.load_into(capistrano_config)
      capistrano_config.load do

        # Check if remote file exists
        #
        def remote_file_exists?(full_path)
          'true' == capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
        end

        # Check if process is running
        #
        def process_exists?(pid_file)
          capture("ps -p $(cat #{pid_file}) ; true").strip.split("\n").size == 2
        end

        # Set unicorn vars
        #
        _cset(:app_env, (fetch(:rails_env) rescue 'production'))
        _cset :unicorn_bin, "bundle exec unicorn"
        _cset(:unicorn_pid, "#{fetch(:current_path)}/tmp/pids/unicorn.pid")
        _cset(:unicorn_env, (fetch(:app_env)))
        _cset :unicorn_std_log, "log/unicorn.stderr.log"
        _cset :unicorn_err_log, "log/unicorn.stderr.log"
        _cset :unicorn_worker_processes, 2
        _cset :unicorn_timeout, 30
        _cset :unicorn_listen_backlog, 2048
        _cset :sidekiq_redis_count, 1
        _cset :sidekiq_redis_url, nil
        _cset :unicorn_hard_restart, false

        namespace :unicorn do
          desc 'Start Unicorn'
          task :start, :roles => :app, :except => {:no_release => true} do
            if remote_file_exists?(unicorn_pid)
              if process_exists?(unicorn_pid)
                logger.important("Unicorn is already running!", "Unicorn")
                next
              else
                run "rm #{unicorn_pid}"
              end
            end

            config_path = "#{current_path}/config/unicorn/#{unicorn_env}.rb"
            if remote_file_exists?(config_path)
              logger.important("Starting...", "Unicorn")
              run "cd #{current_path} && BUNDLE_GEMFILE=#{current_path}/Gemfile bundle exec #{unicorn_bin} -c #{config_path} -E #{app_env} -D"
            else
              logger.important("Config file for \"#{unicorn_env}\" environment was not found at \"#{config_path}\"", "Unicorn")
            end
          end

          desc 'Stop Unicorn'
          task :stop, :roles => :app, :except => {:no_release => true} do
            if remote_file_exists?(unicorn_pid)
              if process_exists?(unicorn_pid)
                logger.important("Stopping...", "Unicorn")
                run "#{try_sudo} kill `cat #{unicorn_pid}`"
              else
                run "rm #{unicorn_pid}"
                logger.important("Unicorn is not running.", "Unicorn")
              end
            else
              logger.important("No PIDs found. Check if unicorn is running.", "Unicorn")
            end
          end

          desc 'Unicorn graceful shutdown'
          task :graceful_stop, :roles => :app, :except => {:no_release => true} do
            if remote_file_exists?(unicorn_pid)
              if process_exists?(unicorn_pid)
                logger.important("Stopping...", "Unicorn")
                run "#{try_sudo} kill -s QUIT `cat #{unicorn_pid}`"
              else
                run "rm #{unicorn_pid}"
                logger.important("Unicorn is not running.", "Unicorn")
              end
            else
              logger.important("No PIDs found. Check if unicorn is running.", "Unicorn")
            end
          end

          desc 'Reload Unicorn'
          task :reload, :roles => :app, :except => {:no_release => true} do
            if remote_file_exists?(unicorn_pid)
              logger.important("Stopping...", "Unicorn")
              if unicorn_hard_restart
                unicorn.stop
                sleep(2)
                unicorn.start
              else
                run "#{try_sudo} kill -s USR2 `cat #{unicorn_pid}`"
              end
            else
              logger.important("No PIDs found. Starting Unicorn server...", "Unicorn")
              config_path = "#{current_path}/config/unicorn/#{unicorn_env}.rb"
              if remote_file_exists?(config_path)
                run "cd #{current_path} && BUNDLE_GEMFILE=#{current_path}/Gemfile bundle exec #{unicorn_bin} -c #{config_path} -E #{app_env} -D"
              else
                logger.important("Config file for \"#{unicorn_env}\" environment was not found at \"#{config_path}\"", "Unicorn")
              end
            end
          end

          desc "Setup unicorn"
          task :setup, :roles => :app, :except => {:no_release => true} do
            run "mkdir -p \"#{shared_path}/config/unicorn\""
            config_path = "#{shared_path}/config/unicorn/#{rails_env}.rb"
            template_path = File.expand_path('../../templates/unicorn/unicorn.rb.erb', __FILE__)
            vars = {
                'application' => application,
                'current_path' => current_path,
                'unicorn_pid' => unicorn_pid,
                'unicorn_std_log' => unicorn_std_log,
                'unicorn_err_log' => unicorn_err_log,
                'stage' => stage,
                'unicorn_listen_backlog' => unicorn_listen_backlog,
                'unicorn_worker_processes' => unicorn_worker_processes,
                'unicorn_timeout' => unicorn_timeout,
                'sidekiq_redis_count' => sidekiq_redis_count,
                'sidekiq_redis_url' => sidekiq_redis_url
            }
            put(render_erb_template(template_path, vars), config_path)
          end
        end

        after :"deploy:restart", :"unicorn:reload"
        after :"deploy:setup", :"unicorn:setup";

        namespace :deploy do
          task :start, :roles => :app do
            unicorn.start
          end

          task :stop, :roles => :app do
            unicorn.stop
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Unicorn::CapistranoIntegration.load_into(Capistrano::Configuration.instance)
end
