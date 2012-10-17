
set :application, ''
set :domain, ''
set :deploy_domain, ''
set :vhost_domain, ''

# set application folder
set :deploy_to, "/var/projects/#{application}/xxx"

set :rails_root, File.expand_path('../../', __FILE__)
set :rails_env, :production # use 'stage' to differ between stage environments

set :user,  'deploy'

server domain, :web, :app, :db, :primary => true

# Multistage settings
#set :stage_dir, File.dirname(__FILE__) + '/deploy/stages'
#set :default_stage, "vagrant"
#require 'capistrano/ext/multistage'

# database
set :db_name, ''
set :db_user_name, ''
set :db_user_password, ''

set :branch, ENV['BRANCH'] || 'develop'
set :repository, 'xxx.git'

set(:shared_directories_to_create) {
  %W(#{shared_path}/bundle #{shared_path}/cache)
}

set(:shared_directories_to_link) {
  {
      "#{shared_path}/bundle/" => "#{release_path}/vendor/bundle"
  }
}

set(:directories_to_create) {
  %W()
}

set(:files_to_link) {
  {
      "#{shared_path}/config/config.#{stage}.yml" => "#{release_path}/config/config.local.yml",
      "#{shared_path}/config/unicorn.#{stage}.rb" => "#{release_path}/config/unicorn.production.rb"
  }
}

set(:files_to_delete) {
  %W()
}

set(:chmods_to_set) {
  {
#    "#{shared_path}/data/pdf"         => 755
  }
}

require 'caploy/recipes/defaults'

require 'caploy/recipes/rbenv'
require 'caploy/recipes/assets'
require 'caploy/recipes/nginx'
require 'caploy/recipes/bundler'
require 'caploy/recipes/symlink'
require 'caploy/recipes/unicorn'
require 'caploy/recipes/setup'
require 'caploy/recipes/monitoring'
require 'caploy/recipes/seeding'
#require 'caploy/recipes/paperclip'
#require 'caploy/recipes/airbrake'
