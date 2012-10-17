Capistrano::Configuration.instance.load do

  _cset :puma_binary, "bundle exec puma"
  _cset :pumactl_binary, "bundle exec pumactl"
  _cset :puma_state, "tmp/puma_state"
  _cset :puma_tcp_port, 9292
  _cset :puma_control_tcp_port, puma_tcp_port.to_i + 1
  _cset :puma_thread_pool, '0:16'

  namespace :deploy do
    task :start, :roles => :app, :except => { :no_release => true } do
      set :puma_socket, fetch(:puma_socket,  "unix:///tmp/sockets/#{application}_#{rails_env}.sock")

      tcp = puma_tcp_port.nil? ? '' : "-b tcp://127.0.0.1:#{puma_tcp_port}"
      run "cd #{current_path} && RAILS_ENV=#{rails_env} #{puma_binary} -t #{puma_thread_pool} -S #{puma_state} --control tcp://127.0.0.1:#{puma_control_tcp_port} -b #{puma_socket} #{tcp}" # --control-token xxx
    end
    task :stop, :roles => :app, :except => { :no_release => true } do
      run "cd #{current_path} && RAILS_ENV=#{rails_env} #{pumactl_binary} -S #{puma_state} stop"
    end
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "cd #{current_path} && RAILS_ENV=#{rails_env} #{pumactl_binary} -S #{puma_state} restart"
    end
  end

end
