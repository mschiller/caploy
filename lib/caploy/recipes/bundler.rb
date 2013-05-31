Capistrano::Configuration.instance.load do

  # defaults
  #_cset :bundle_gemfile,  "Gemfile"
  #_cset :bundle_dir,      File.join(fetch(:shared_path), 'bundle')
  #_cset :bundle_roles,    #{role_default} # e.g. [:app, :batch]
  #_cset :rake, "bundle --gemfile Gemfile.server exec rake"
  _cset :bundle_cmd,      "bundle"
  _cset :bundle_without,  [:development, :test, :deploy]

  # http://shapeshed.com/journal/using-rbenv-to-manage-rubies/
  # you can also apply a clever technique to allow you switch versions of ruby by pushing a new .rbenv-version file with capistrano. From version 1.1rc bundler allows you to specify a shebang for binstubs. To use this add the following to your capistrano recipe.
  _cset :bundle_flags,    "--deployment --quiet --binstubs --shebang ruby-local-exec"
  _cset :rake, 'bundle exec rake'

  require 'bundler/capistrano'

  namespace :bundler do
    task :install_gem do
      run "cd #{release_path} && gem install bundler --no-ri --no-rdoc"
    end
  end

  #before "bundle:install", "bundler:install_gem"
end
