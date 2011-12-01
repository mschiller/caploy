Capistrano::Configuration.instance.load do

  namespace :deploy do
    desc <<-DESC
      Symlink shared directories and files.
    DESC
    task :symlink_dependencies do
      shared_directories_to_link   = fetch(:shared_directories_to_link, [])
      directories_to_create        = fetch(:directories_to_create, [])
      files_to_delete              = fetch(:files_to_delete, [])
      files_to_link                = fetch(:files_to_link, {})
      chmods_to_set                = fetch(:chmods_to_set, [])

      directories_to_create.each        { |directory| run "mkdir -p #{directory}" }
      shared_directories_to_link.each   { |source, target| run "ln -s #{source} #{target}" }
      files_to_delete.each              { |file| run "rm #{file}" }
      files_to_link.each                { |source, target| run "ln -s #{source} #{target}"}
      chmods_to_set.each                { |target, chmod| run "chmod #{chmod} #{target}" }
    end
  end

  after 'deploy:symlink', 'deploy:symlink_dependencies'

end
