require 'yaml'

Capistrano::Configuration.instance.load do

  namespace :deploy do
    namespace :prepare do
      task :database do
        set_unless :db_admin_user, 'root'
        set_unless :db_admin_password, Capistrano::CLI.password_prompt("Type your mysql password for user #{db_admin_user}: ")
        set_unless :db_name, application.to_s + '_' + rails_env.to_s
        set_unless :db_password, database_config['password']

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
       GRANT ALL PRIVILEGES ON #{db_name}.* TO #{application}@localhost IDENTIFIED BY '#{db_password}';
    SQL

    run "mysql --user=#{db_admin_user} --password=#{db_admin_password} --execute=\"#{grant_sql}\""
  end

end
