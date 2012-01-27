Capistrano::Configuration.instance.load do

  namespace :deploy do
    namespace :assets do
      desc "Compile assets"
      task :compile, :roles => :web do
        run "cd #{release_path}; RAILS_ENV=#{rails_env} #{rake} assets:precompile"
      end

      #after 'deploy', 'deploy:assets:compile'
      #after 'deploy:migrations', 'deploy:assets:compile'

    end
  end
end
