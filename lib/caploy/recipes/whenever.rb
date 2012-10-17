Capistrano::Configuration.instance.load do

  #set :whenever_environment, defer { stage }
  #set :whenever_identifier, defer { "#{application}_#{stage}" }
  #set :whenever_command, "bundle exec whenever"
  #require "whenever/capistrano"

end
