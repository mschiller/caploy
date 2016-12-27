
set :rake, "#{fetch(:rbenv_prefix)} bundle exec rake"

namespace :deploy do
  task :restart do
    invoke 'unicorn:restart'
  end

  desc 'build missing paperclip styles'
  task :build_missing_paperclip_styles do # app
    run "cd #{current_path}; RAILS_ENV=#{rails_env} #{fetch(:rake)} paperclip:refresh:missing_styles"
  end

  desc 'generate nondigest assets after default precompiling'
  task :compile_nondigest_assets do
    on roles(:app) do
      execute "cd #{release_path}; RAILS_ENV=#{fetch(:rails_env)} #{fetch(:rake)} assets:precompile:nondigest"
    end
  end
  after 'deploy:compile_assets', 'deploy:compile_nondigest_assets'

  desc "checks whether the currently checkout out revision matches the remote one we're trying to deploy from"
  task :check_revision do
    branch = fetch(:branch)
    unless `git rev-parse HEAD` == `git rev-parse origin/#{branch}`
      puts "WARNING: HEAD is not the same as origin/#{branch}"
      puts "Run `git push` to sync changes or make sure you've"
      puts "checked out the branch: #{branch} as you can only deploy"
      puts "if you've got the target branch checked out"
      exit
    end
  end

  desc 'compiles assets locally then rsyncs'
  task :compile_assets_locally do
    run_locally do
      execute "RAILS_ENV=#{fetch(:rails_env)} bundle exec rake assets:precompile"
    end
    on roles(:app) do |role|
      run_locally do
        execute "rsync -av ./public/assets/ #{role.user}@#{role.hostname}:#{release_path}/public/assets/;"
      end
      sudo "chmod -R 755 #{release_path}/public/assets/"
    end
    run_locally do
      execute 'rm -rf ./public/assets'
    end
  end

  desc 'Run the full tests on the deployed app. To deploy without tests, try cap deploy:without_tests or cap -S run_tests=0 deploy'
  task :run_tests do
    unless fetch(:run_tests, '1') == '0'
      run "cd #{release_path} && #{fetch(:rake)} db:test:prepare"
      run "cd #{release_path} && nice -n 10 #{fetch(:rake)} RAILS_ENV=production test"
    end
  end

  desc 'deploy without running tests'
  task :without_tests do
    set(:run_tests, '0')
    deploy.default
  end

  task :set_branch_info_file do
    on roles(:app) do
      run "cd #{release_path} && echo \"#{branch}\" > CURRENT_BRANCH"
    end
  end

  namespace :cache do
    desc "Flush cache"
    task :clear do
      on roles(:app) do
        run "cd #{current_path} && #{fetch(:rake)} cache:clear RAILS_ENV=#{rails_env}"
      end
    end
  end

  desc 'Show deployed revision'
  task :revision do
    on roles(:app) do
      run "cat #{current_path}/REVISION"
    end
  end

  desc 'Show currently deployed revision on server.'
  task :revisions do
    on roles(:app) do
      current, previous, latest = current_revision[0, 7], previous_revision[0, 7], real_revision[0, 7]
      puts "\n" << "-"*63
      puts "===== Master Revision: \033[1;33m#{latest}\033[0m\n\n"
      puts "===== [ \033[1;36m#{application.capitalize} - #{stage.to_s.capitalize}\033[0m ]"
      puts "=== Deployed Revision: \033[1;32m#{current}\033[0m"
      puts "=== Previous Revision: \033[1;32m#{previous}\033[0m\n\n"

      # If deployed and master are the same, show the difference between the last 2 deployments.
      base_label, new_label, base_rev, new_rev = latest != current ? \
         ['deployed', 'master', current, latest] : \
         ['previous', 'deployed', previous, current]

      # Fetch the difference between master and deployed revisions.
      log_cmd = "#{source.log(previous, latest).gsub(/^git/, 'git --no-pager')} --oneline"
      cfg = File.join(shared_path, strategy.configuration[:repository_cache] || "cached-copy")

      diff = ''
      run %Q{cd "#{cfg}" && #{log_cmd}} do |channel, stream, data|
        diff = data
      end

      # Show difference between master and deployed revisions.
      if diff != ""
        # Colorize refs
        diff.gsub!(/^([a-f0-9]+) /, "\033[1;32m\\1\033[0m - ")
        diff = "    " << diff.gsub("\n", "\n    ") << "\n"
        # Indent commit messages nicely, max 80 chars per line, line has to end with space.
        diff = diff.split("\n").map { |l| l.scan(/.{1,80}/).join("\n"<<" "*14).gsub(/([^ ]*)\n {14}/m, "\n"<<" "*14<<"\\1") }.join("\n")
        puts "=== Difference between #{base_label} revision and #{new_label} revision:\n\n"
        puts diff
      end
    end
  end

  # make sure we're deploying what we think we're deploying
  # before :deploy, 'deploy:check_revision'

  # only allow a deploy with passing tests to deployed
  # before :deploy, 'deploy:run_tests'

  # setup section
  #
  # # remove the default nginx configuration as it will tend
  # # to conflict with our configs.
  # before 'deploy:setup_config', 'nginx:remove_default_vhost'
  #
  # # reload nginx to it will pick up any modified vhosts from
  # # setup_config
  # after 'deploy:setup_config', 'nginx:reload'

  # whether we're using ssl or not, used for building nginx
  # config file
  # set :enable_ssl, false

  #
  # set :nginx_protocol, :
  #
  # if you want to remove the dump file after loading
  # set :db_local_clean, true
end
