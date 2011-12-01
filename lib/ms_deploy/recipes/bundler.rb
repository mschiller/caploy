
# defaults
#set :bundle_gemfile,  "Gemfile"
#set :bundle_dir,      File.join(fetch(:shared_path), 'bundle')
#set :bundle_without,  [:development, :test]
#set :bundle_roles,    #{role_default} # e.g. [:app, :batch]

set :bundle_cmd,      "/home/deploy/.rbenv/shims/bundle"
# http://shapeshed.com/journal/using-rbenv-to-manage-rubies/
# you can also apply a clever technique to allow you switch versions of ruby by pushing a new .rbenv-version file with capistrano. From version 1.1rc bundler allows you to specify a shebang for binstubs. To use this add the following to your capistrano recipe.
set :bundle_flags,    "--deployment --quiet --binstubs --shebang ruby-local-exec"

require 'bundler/capistrano'

set :rake, 'bundle exec rake'

namespace :bundler do
  task :install_gem do
    run "cd #{current_path} && gem install bundler --pre --no-ri --no-rdoc"
  end
end

before "bundle:install", "bundler:install_gem"
