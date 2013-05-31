Capistrano::Configuration.instance.load do

  namespace :deploy do
    task :seed, :roles => :app do
      run "cd #{current_path} && RAILS_ENV=#{rails_env} #{rake} db:seed"
    end
  end

end
