Capistrano::Configuration.instance.load do

  require File.expand_path("#{File.dirname(__FILE__)}/../../util")

  set :keep_releases, 10
  set :use_sudo, false

  set :nginx_protocol, :both

  set :scm, :git
  set :git_enable_submodules, false

  # set deployment strategy
  set :deploy_via, :remote_cache
  set :copy_exclude, %w(.git .svn .DS_Store test doc .gitkeep)
  #_cset :repository_cache, "cached-copy" # defaults to :shared_path + 'cached-copy/'

  # :forward_agent allows us to avoid using and distributing a deploy key.
  # On problems run 'ssh-add' locally
  # In your /etc/ssh/ssh_config or ~/.ssh/config you need to have ForwardAgent enabled for this to work.
  set :ssh_options, {:port => fetch(:ssh_port, 22), :forward_agent => true, :paranoid => true}

  default_run_options[:pty] = true

  # if you want to remove the dump file after loading
  set :db_local_clean, true

  namespace :deploy do
    desc "deploy always with migrations"
    task :default do
      deploy.migrations
    end

    namespace :cache do
      desc "Flush cache"
      task :clear, :roles => :cache do
        run "cd #{current_path} && #{rake} cache:clear  RAILS_ENV=#{stage}"
      end
    end

    task :set_branch_info_file, :roles => :app do
      run "cd #{release_path} && echo \"#{branch}\" > CURRENT_BRANCH"
    end

    task :set_staging_release_test_info_file, :roles => :app do
      run "cd #{release_path} && echo \"#{branch}\" > RELEASE_TEST" if branch == 'master' and ENV['RELEASE_TEST']
    end

    desc "build missing paperclip styles"
    task :build_missing_paperclip_styles, :roles => :app do
      run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake paperclip:refresh:missing_styles"
    end

    desc 'Show deployed revision'
    task :revision, :roles => :app do
      run "cat #{current_path}/REVISION"
    end

    after 'deploy:finalize_update', 'deploy:set_branch_info_file'
  end

  task :test_and_prepare_cap_env do
    abort "You must set :user before using defaults" unless fetch(:user, nil)
    abort "You must set :repository before using defaults" unless fetch(:repository, nil)
    abort "You must set :branch before using defaults" unless fetch(:branch, nil)
    abort "You must set :deploy_to before using defaults" unless fetch(:deploy_to, nil)

    set :uptodate_branch, fetch(:branch)
    set :uptodate_scm, :git
    #:uptodate_scm_bynary ('git') - path to SCM binary
    #:uptodate_remote_repository ('origin') - remote repository
    #:uptodate_time (60) - time in seconds for checking remote repository
    #:uptodate_behaviour - (:confirm)
    # :confirm - show outdated message and ask to confirm the further execution
    # :abort - show outdated message and abort further execution
    require 'capistrano/uptodate'

    require 'capistrano_colors'
    capistrano_color_matchers = [
        {:match => /command finished/, :color => :hide, :prio => 10},
        {:match => /executing command/, :color => :blue, :prio => 10, :attribute => :underscore},
        {:match => /^transaction: commit$/, :color => :magenta, :prio => 10, :attribute => :blink},
        {:match => /git/, :color => :white, :prio => 20, :attribute => :reverse},
    ]
    colorize(capistrano_color_matchers)

    #Dynamically skip Capistrano hooks example
    # before 'deploy:update_code', 'db:dump' unless fetch(:skip_dump, false)
    # $ cap staging deploy -S skip_dump=true
  end

  before 'deploy', 'test_and_prepare_cap_env'
  before 'deploy:migrations', 'test_and_prepare_cap_env'
  after 'deploy:update', 'deploy:cleanup'

  desc "Show currently deployed revision on server."
  task :revisions, :roles => :app do
    current, previous, latest = current_revision[0, 7], previous_revision[0, 7], real_revision[0, 7]
    puts "\n" << "-"*63
    puts "===== Master Revision: \033[1;33m#{latest}\033[0m\n\n"
    puts "===== [ \033[1;36m#{application.capitalize} - #{stage.to_s.capitalize}\033[0m ]"
    puts "=== Deployed Revision: \033[1;32m#{current}\033[0m"
    puts "=== Previous Revision: \033[1;32m#{previous}\033[0m\n\n"

    # If deployed and master are the same, show the difference between the last 2 deployments.
    base_label, new_label, base_rev, new_rev = latest != current ? \
         ["deployed", "master", current, latest] : \
         ["previous", "deployed", previous, current]

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
  after "deploy", "revisions"
  after "deploy:migrations", "revisions"
end
