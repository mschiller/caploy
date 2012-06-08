Capistrano::Configuration.instance.load do

  set :unicorn_bin, "bundle exec unicorn"
  set :unicorn_config, "config/unicorn.#{fetch(:stage, 'production')}.rb"
  set :unicorn_pid, "tmp/pids/unicorn.pid"

  #require "capistrano-unicorn"

  namespace :deploy do
    desc 'Start unicorn'
    task :start, :roles => :app, :except => {:no_release => true} do
      run "cd #{current_path} && #{try_sudo} #{unicorn_bin} -c #{current_path}/#{unicorn_config} -E #{rails_env} -D"
    end

    desc 'Stop unicorn'
    task :stop, :roles => :app, :except => {:no_release => true} do
      run "if [ -f #{current_path}/#{unicorn_pid} ]; then #{try_sudo} kill -QUIT `cat #{current_path}/#{unicorn_pid}`; fi"
    end

    desc 'Restart unicorn'
    task :restart, :roles => :app, :except => {:no_release => true} do
      run "cd #{current_path} && #{try_sudo} kill -USR2 `cat #{current_path}/#{unicorn_pid}`"
    end
  end
end
