Capistrano::Configuration.instance.load do

  namespace :deploy do
    namespace :prepare do
      task :create_config do
        run "mkdir -p #{shared_path}/config/"
        put(File.read(database_config_file), "#{shared_path}/config/#{fetch(:configuration_file_prefix, 'config')}.production.yml", :via => :scp)
      end

      task :create_database_config do
        run "mkdir -p #{shared_path}/config/"
        put(File.read(database_config_file), "#{shared_path}/config/database.yml", :via => :scp)
      end

      desc "Set up shared directory structure"
      task :create_shared_folders do
        shared_directories_to_create.each { |directory| run "mkdir -p #{directory}" }
      end

      #desc "Rebuilds css and js asset packages"
      #task :rebuild_asset_cache, :roles => :app do
      #  run "cd #{current_path} && #{rake_path} RAILS_ENV=#{fetch(:rails_env, "production")} asset:packager:build_all"
      #end
    end
  end

  before :"deploy:setup", :"deploy:prepare:create_config";
  before :"deploy:setup", :"deploy:prepare:create_database_config";
  before :"deploy:setup", :"deploy:prepare:create_shared_folders";

end

def database_config_file
  config_file = "#{rails_root}/config/#{fetch(:configuration_file_prefix, 'config')}.#{fetch(:stage, 'production')}.yml"
  raise "No config file '#{config_file}' for '#{fetch(:stage, 'production')}'" unless File.exists? config_file
  config_file
end
