Capistrano::Configuration.instance.load do

  _cset :unicorn_bin, "bundle exec unicorn"
  _cset :unicorn_pid, "#{deploy_to}/current/tmp/pids/unicorn.pid"
  _cset :unicorn_std_log, "log/unicorn.stderr.log"
  _cset :unicorn_err_log, "log/unicorn.stderr.log"
  _cset :unicorn_worker_processes, 2
  _cset :unicorn_listen_backlog, 2048
  _cset :sidekiq_redis_count, 1

  require "capistrano-unicorn"

  namespace :unicorn do
    desc "Setup unicorn"
    task :setup, :roles => :app, :except => { :no_release => true } do
    run "mkdir -p \"#{shared_path}/config/unicorn\""
      config_path = "#{shared_path}/config/unicorn/#{rails_env}.rb"
      template_path = File.expand_path('../../templates/unicorn/unicorn.rb.erb', __FILE__)
      vars = {
          'application'=> application,
          'current_path' => current_path,
          'unicorn_pid' => unicorn_pid,
          'unicorn_std_log' => unicorn_std_log,
          'unicorn_err_log' => unicorn_err_log,
          'stage' => stage,
          'unicorn_listen_backlog' => unicorn_listen_backlog,
          'unicorn_worker_processes' => unicorn_worker_processes,
          'sidekiq_redis_count' => sidekiq_redis_count
      }
      put(render_erb_template(template_path, vars), config_path)
    end
  end

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
