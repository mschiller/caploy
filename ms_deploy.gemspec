# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ms_deploy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Michael Schiller"]
  gem.email         = ["michael.schiller@gmx.de"]
  gem.description   = %q{capistrano deployment task for my projects}
  gem.summary       = %q{capistrano deployment task for my projects}
  gem.homepage      = "https://github.com/mschiller/ms_deploy"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "ms_deploy"
  gem.require_paths = ["lib"]

  gem.add_dependency('capistrano')
  gem.add_dependency('capistrano-ext')
  gem.add_dependency('erubis')

  gem.version       = MsDeploy::VERSION
end
