namespace :deploy do
  desc 'build missing paperclip styles'
  task :build_missing_paperclip_styles do
    on roles(:app) do
      execute "cd #{current_path}; RAILS_ENV=production bundle exec rake paperclip:refresh:missing_styles"
    end
  end
end

after('deploy:compile_assets', 'deploy:build_missing_paperclip_styles')
