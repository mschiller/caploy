Capistrano::Configuration.instance.load do

    namespace :passenger do
    desc "Restart Application"
    task :restart do
      run "touch #{current_path}/tmp/restart.txt"
    end
  end

  namespace :deploy do
    #desc "Archive images from public tree"
    #task :archive_images do
    #  run "tar -c public/system > images.tar"
    #end
    #
    #desc "Install images into deployed public tree"
    #task :install_images do
    #  # scp images to server
    #  # untar images into public/
    #end

    task :restart do
      passenger.restart
    end

    task :start do
    end

    task :stop do
    end
  end
end