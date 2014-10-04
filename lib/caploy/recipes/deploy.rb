
# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# And/or per server (overrides global)
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }

#set :unicorn_hard_restart, true if ENV['HARD_RESTART']

# what specs should be run before deployment is allowed to
# continue, see lib/capistrano/tasks/run_tests.cap
# set :tests, []

# files which need to be symlinked to other parts of the
# filesystem. For example nginx virtualhosts, log rotation
# init scripts etc.
# set(:symlinks, [
#   {
#     source: "nginx.conf",
#     link: "/etc/nginx/sites-enabled/#{fetch(:full_app_name)}"
#   },
#   {
#     source: "unicorn_init.sh",
#     link: "/etc/init.d/unicorn_#{fetch(:full_app_name)}"
#   }
# ])

# which config files should be copied by deploy:setup_config
# see documentation in lib/capistrano/tasks/setup_config.cap
# for details of operations
# set(:config_files, %w(
#   nginx.conf
#   database.example.yml
#   unicorn.rb
#   unicorn_init.sh
# ))

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

namespace :deploy do
  task :restart do
    invoke 'unicorn:restart'
  end

  desc 'build missing paperclip styles'
  task :build_missing_paperclip_styles do # app
    run "cd #{current_path}; RAILS_ENV=#{rails_env} #{rake} paperclip:refresh:missing_styles"
  end

  desc "checks whether the currently checkout out revision matches the
  remote one we're trying to deploy from"
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
      run "cd #{release_path} && rake db:test:prepare"
      run "cd #{release_path} && nice -n 10 rake RAILS_ENV=production test"
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
        run "cd #{current_path} && #{rake} cache:clear RAILS_ENV=#{rails_env}"
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
  #after 'deploy', 'revisions'

  after :finishing, 'deploy:cleanup'
  after 'deploy:publishing', 'deploy:restart'
  after 'deploy:symlink:shared', 'deploy:compile_assets_locally'
  #after('deploy:compile_assets', 'deploy:build_missing_paperclip_styles')

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
