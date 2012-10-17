Capistrano::Configuration.instance.load do
  abort "You must set :ruby_version before using defaults" unless fetch(:ruby_version)

  #$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
  require "rvm/capistrano"
  set :rvm_ruby_string, fetch(:ruby_version)
  set :rvm_type, :user
end
