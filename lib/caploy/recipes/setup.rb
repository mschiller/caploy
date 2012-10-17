Capistrano::Configuration.instance.load do

  namespace :deploy do
    namespace :prepare do
      task :create_config_files, :roles => :app do
        run "mkdir -p #{shared_path}/config/"
        config_file_to_setup.each do |config_file|
          put(File.read(config_file_path(config_file)), "#{shared_path}/config/#{config_file}", :via => :scp)
        end
      end

      desc "Set up shared directory structure"
      task :create_shared_folders, :roles => :app do
        directories_to_create.each { |directory| run "mkdir -p #{directory}" }
      end

      task :set_permissions, :roles => :app do
        try_sudo "chown -R #{user}:#{fetch(:group, user)} #{deploy_to}" if fetch(:use_sudo, false)
      end

      task :database, :roles => :db do
        _cset :db_admin_user, 'root'
        _cset :db_admin_password, Capistrano::CLI.password_prompt("Type your mysql password for user '#{db_admin_user}' (not set if empty): ")
        _cset :db_name, application.gsub(/\W+/, '')[0..5] + '_' + rails_env.to_s
        _cset :db_user_name, application
        _cset :db_user_password, ''

        unless db_admin_password.to_s.empty?
          unless database_exits?
            create_database
          end
          setup_database_permissions
        end
      end
    end
  end

  before 'deploy:setup', 'deploy:prepare:database';
  before :'deploy:setup', :'deploy:prepare:create_config_files';
  before :'deploy:setup', :'deploy:prepare:create_shared_folders';
  after 'deploy:setup', 'deploy:prepare:set_permissions';

end

def config_file_path(config_file_name)
  config_file = "#{rails_root}/config/#{config_file_name}"
  raise "No config file '#{config_file}'" unless File.exists? config_file
  config_file
end

def database_exits?
  exists = false

  run "mysql --user=#{db_admin_user} --password=#{db_admin_password} --execute=\"show databases;\"" do |channel, stream, data|
    exists = exists || data.include?(db_name)
  end

  exists
end

def create_database
  create_sql = <<-SQL
      CREATE DATABASE #{db_name};
  SQL

  run "mysql --user=#{db_admin_user} --password=#{db_admin_password} --execute=\"#{create_sql}\""
end

def setup_database_permissions
  grant_sql = <<-SQL
     GRANT ALL PRIVILEGES ON #{db_name}.* TO #{db_user_name}@localhost IDENTIFIED BY '#{db_user_password}';
  SQL

  run "mysql --user=#{db_admin_user} --password=#{db_admin_password} --execute=\"#{grant_sql}\""
end
