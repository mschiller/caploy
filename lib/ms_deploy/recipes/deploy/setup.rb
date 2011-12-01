Capistrano::Configuration.instance.load do

  rails_root = File.expand_path('../../../', __FILE__)

  namespace :deploy do
    namespace :prepare do
      task :create_config do
        config_file = "#{rails_root}/#{fetch(:configuration_file_prefix, 'config')}.#{fetch(:stage, 'production')}.yml"
        raise "No '#{rails_root}/#{fetch(:configuration_file_prefix, 'config')}.#{fetch(:stage, 'production')}.yml' config file for '#{fetch(:stage, 'production')}'" unless File.exists? config_file

        run "mkdir -p #{shared_path}/config/"
        put(File.read(config_file), "#{shared_path}/config/#{fetch(:configuration_file_prefix, 'config')}.production.yml", :via => :scp)
      end

      task :create_database_config do
        config_file = "#{rails_root}/database.#{fetch(:stage, 'production')}.yml"
        raise "No '#{rails_root}/database.#{fetch(:configuration_file_prefix, 'config')}.#{fetch(:stage, 'production')}.yml' config file for '#{fetch(:stage, 'production')}'" unless File.exists? config_file

        run "mkdir -p #{shared_path}/config/"
        put(File.read(config_file), "#{shared_path}/config/database.yml", :via => :scp)
      end

      desc "Set up shared directory structure"
      task :create_shared_folders do
        shared_directories_to_create.each { |directory| run "mkdir -p #{directory}" }
      end

      #desc "Rebuilds css and js asset packages"
      #task :rebuild_asset_cache, :roles => :app do
      #  run "cd #{current_path} && #{rake_path} RAILS_ENV=#{fetch(:rails_env, "production")} asset:packager:build_all" # If you’d like to prevent Capistrano from applying your Moonshine manifests for any reason:
      #end
    end
  end

  before :"deploy:setup", :"deploy:prepare:create_config";
  before :"deploy:setup", :"deploy:prepare:create_database_config";
  before :"deploy:setup", :"deploy:prepare:create_shared_folders";

end
