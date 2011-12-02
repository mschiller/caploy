require 'yaml'

Capistrano::Configuration.instance.load do

  namespace :deploy do
    namespace :prepare do
      task :database do
        set :db_admin_user, 'root' unless fetch(:db_admin_user, nil)
        set :db_admin_password, Capistrano::CLI.password_prompt("Type your mysql password for user '#{db_admin_user}': ") unless fetch(:db_admin_password, nil)
        set :db_name, application.gsub(/\W+/, '')[0..5] + '_' + rails_env.to_s unless fetch(:db_name, nil)
        set :db_user_name, 'root' unless fetch(:db_user_name, nil)
        set :db_user_password, '' unless fetch(:db_user_password, nil)

        unless database_exits?
          create_database
        end
        setup_database_permissions
      end
    end
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

end
