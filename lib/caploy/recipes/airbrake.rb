Capistrano::Configuration.instance.load do
  require './config/boot'
  require 'airbrake/capistrano'
end
