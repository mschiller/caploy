require 'caploy/version'

module Caploy
  require 'caploy/railtie' if defined?(Rails)

  # Load DSL and Setup Up Stages
  require 'capistrano/setup'

  # Includes default deployment tasks
  require 'capistrano/deploy'

  # Includes tasks from other gems included in your Gemfile
  require 'capistrano/rails'
  require 'capistrano/rbenv'
  require 'capistrano3/unicorn'
end
