Capistrano::Configuration.instance.load do

  namespace :deploy do
    namespace :assets, :roles => :web do
      desc "Compile assets"
      task :compile do
        run "cd #{release_path}; RAILS_ENV=#{rails_env} #{rake} assets:precompile"
      end

      task :symlink, :roles => :web, :except => {:no_release => true} do
        # fixme do nothing, rails 3.1
      end

      after 'deploy:symlink_dependencies', 'deploy:assets:compile'

    end
  end
end
