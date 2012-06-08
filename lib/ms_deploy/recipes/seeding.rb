Capistrano::Configuration.instance.load do

  namespace :deploy do
    task :seed do
      run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake db:seed"
    end
  end

end
