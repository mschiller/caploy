Capistrano::Configuration.instance.load do
  abort "You must set :user before using defaults" unless fetch(:user)

  set :default_environment, {
      'PATH' => "/home/#{fetch(:user)}/.rbenv/shims:/home/#{fetch(:user)}/.rbenv/bin:$PATH"
  }
end
