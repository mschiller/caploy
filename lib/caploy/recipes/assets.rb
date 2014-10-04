Capistrano::Configuration.instance.load do
  namespace :local do
    desc 'Synchronize your local assets using remote assets'
    task :sync do
      if Util.prompt "Are you sure you want to erase your local assets with server assets"
        servers = find_servers :roles => :app
        [assets_dir].flatten.each do |dir|
          system("rsync -a --del --progress --rsh='ssh -p #{fetch(:ssh_port, 22)}' #{user}@#{servers.first}:#{shared_path}/#{dir}/ #{local_assets_dir}")
        end
      end
    end
  end

  desc 'Synchronize your local assets using remote assets'
  task :pull do
    assets.local.sync
  end
end
