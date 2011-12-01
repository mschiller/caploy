Capistrano::Configuration.instance.load do

  namespace :deploy do
    desc "Compile assets"
    task :assets do
      run "cd #{release_path}; RAILS_ENV=#{rails_env} #{rake} assets:precompile"
    end
  end

  after 'deploy:symlink_dependencies', 'deploy:assets'

end
