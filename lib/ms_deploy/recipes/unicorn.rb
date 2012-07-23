Capistrano::Configuration.instance.load do

  set :unicorn_bin, "bundle exec unicorn"
  set :unicorn_pid, "tmp/pids/unicorn.pid"
  #require "capistrano-unicorn"

  namespace :deploy do
    desc "Zero-downtime restart of Unicorn"
    task :restart, :except => { :no_release => true } do
      stop
      start
    end

    desc "Start unicorn"
    task :start, :except => { :no_release => true } do
      set :unicorn_config, "config/unicorn.#{fetch(:stage, 'production')}.rb"
      run "cd #{current_path} && #{try_sudo} #{unicorn_bin} -c #{current_path}/#{unicorn_config} -E #{rails_env} -D"
    end

    desc "Stop unicorn"
    task :stop, :except => { :no_release => true } do
      run "kill -s QUIT `cat #{shared_path}/pids/unicorn.pid`;exit 0"
    end
  end
end
