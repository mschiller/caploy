# -*- encoding: utf-8 -*-
require File.expand_path('../lib/caploy/version', __FILE__)

Gem::Specification.new do |spec|
  spec.authors       = ['Michael Schiller']
  spec.email         = ['michael.schiller@gmx.de']
  spec.description   = %q{capistrano deployment helpling}
  spec.summary       = %q{capistrano deployment tasks for different projects}
  spec.homepage      = 'https://github.com/mschiller/caploy'
  spec.license       = 'MIT'

  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.name          = 'caploy'
  spec.require_paths = ['lib']

  spec.add_dependency('gemcutter')

  spec.add_dependency('capistrano', '~> 3.6')
  spec.add_dependency('capistrano-rails', '~> 1.2')
  spec.add_dependency('capistrano-rbenv', '~> 2.0')
  spec.add_dependency('capistrano3-unicorn', '~> 0.2')
  spec.add_dependency('capistrano-bundler', '~> 1.2')

  spec.version       = Caploy::VERSION
end
