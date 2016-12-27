require 'caploy'
require 'rails'

module Caploy
  class Railtie < Rails::Railtie
    railtie_name :caploy

    rake_tasks do
      Dir[File.join(File.dirname(__FILE__), 'tasks/*.rake')].each { |f| load f }
    end
  end
end
