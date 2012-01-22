
set :application, ''
set :domain, ''
set :deploy_domain, ''
set :vhost_domain, ''

set :user,  'deploy'
set :group, 'deploy'

set :ruby_version, "ruby-1.9.3.rc1"
set :rails_root, File.expand_path('../../', __FILE__)

set :default_environment, {
        'PATH' => "/home/#{user}/.rbenv/shims:/home/#{user}/.rbenv/bin:$PATH"
}

set :rails_env, :production # use 'stage' to differ between stage environments
set :keep_releases, 10 # default
set :use_sudo, false

server domain, :web, :app, :db, :primary => true

set :branch do
  ENV['BRANCH'] || 'xxx'
end

# Multistage settings
#set :stage_dir, File.dirname(__FILE__) + '/deploy/stages'
#set :default_stage, "vagrant"
#
#require 'capistrano/ext/multistage'

# database
set :db_name, ''
set :db_user_name, ''
set :db_user_password, ''

set :scm, :git
set :repository, '.git'
set :git_enable_submodules, 1

# set deployment strategy
set :deploy_via, :remote_cache
set :copy_exclude, %w(.git .svn .DS_Store test doc .gitkeep)

# :forward_agent allows us to avoid using and distributing a deploy key.
# On problems run 'ssh-add' locally
# In your /etc/ssh/ssh_config or ~/.ssh/config you need to have ForwardAgent enabled for this to work.
set :ssh_options, { :port => fetch(:ssh_port, 22), :forward_agent => true, :paranoid => true }

default_run_options[:pty] = true

# set application folder
set(:deploy_to) { "/var/projects/#{application}/#{fetch(:stage, 'production')}" }

require 'ms_deploy/recipes/nginx'
require 'ms_deploy/recipes/bundler'
require 'ms_deploy/recipes/deploy/symlink'
require 'ms_deploy/recipes/deploy/unicorn'
require 'ms_deploy/recipes/deploy/setup'
require 'ms_deploy/recipes/deploy/assets'

before 'deploy:setup', 'deploy:prepare:database';
after  'deploy:update", "deploy:cleanup'

set(:shared_directories_to_create) {
  [
    "#{shared_path}/vendor/bundle",
    "#{shared_path}/vendor/cache",
    "#{shared_path}/uploads"
  ]
}

set(:shared_directories_to_link) {
  {
    "#{shared_path}/bundle/" => "#{release_path}/vendor/bundle"
  }
}

set(:directories_to_create) {
  [
    "#{release_path}/tmp",
    "#{release_path}/vendor"
  ]
}

set(:files_to_link) {
  {
    "#{shared_path}/config/config.#{stage}.yml" => "#{release_path}/config/config.local.yml",
    "#{shared_path}/config/unicorn.#{stage}.rb" => "#{release_path}/config/unicorn.production.rb"
  }
}

set(:config_file_to_setup) {
  [
    "config.#{stage}.yml",
    "unicorn.#{stage}.rb"
  ]
}

set(:files_to_delete) {
  [
  ]
}

set(:chmods_to_set) {
  {
#    "#{shared_path}/data/pdf"         => 755
  }
}
