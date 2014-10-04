namespace :deploy do
  task :seed do
    on roles(:app) do
      run "cd #{current_path} && RAILS_ENV=#{rails_env} #{rake} db:seed"
    end
  end
end
