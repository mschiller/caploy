Capistrano::Configuration.instance.load do |instance|

  require File.expand_path("#{File.dirname(__FILE__)}/../../util")
  require File.expand_path("#{File.dirname(__FILE__)}/../../mysql")

  instance.set :local_rails_env, ENV['RAILS_ENV'] || 'development' unless exists?(:local_rails_env)
  instance.set :db_local_clean, false unless exists?(:db_local_clean)

  namespace :db do
    namespace :remote do
      desc 'Synchronize the local database to the remote database'
      task :sync, :roles => :db do
        if if Util.prompt 'Are you sure you want to REPLACE THE REMOTE DATABASE with local database'
             Database.local_to_remote(instance)
           end
        end
      end

      namespace :local do
        desc 'Synchronize your local database using remote database data'
        task :sync, :roles => :db do
          puts "Local database: #{Database::Local.new(instance).database}"
          if rails_env == 'production'
            puts 'Never sync remote production database!'
          else
            if Util.prompt 'Are you sure you want to erase your local database with server database'
              Database.remote_to_local(instance)
            end
          end
        end
      end

      desc 'Synchronize your local database using remote database data'
      task :pull do
        db.local.sync
      end

      desc 'Synchronize the local database to the remote database'
      task :push do
        db.remote.sync
      end
    end
  end
end