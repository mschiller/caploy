# -*- encoding: utf-8 -*-
require File.expand_path('../lib/caploy/version', __FILE__)

Gem::Specification.new do |spec|
  spec.authors       = ['Michael Schiller']
  spec.email         = ['michael.schiller@gmx.de']
  spec.description   = %q{capistrano deployment tasks}
  spec.summary       = %q{capistrano deployment tasks for different projects}
  spec.homepage      = 'https://github.com/mschiller/caploy'
  spec.license       = 'MIT'

  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.name          = "caploy"
  spec.require_paths = ['lib']

  spec.add_dependency('gemcutter')

  spec.add_dependency('capistrano', '>= 2.13.5')
  spec.add_dependency('capistrano-ext', '>= 1.2.1')
  spec.add_dependency('capistrano_colors', '>= 0.5.5')
  spec.add_dependency('capistrano-file_db', '>= 0.1.0')
  spec.add_dependency('capistrano-uptodate', '>= 0.0.2')
  spec.add_dependency('capistrano-multiconfig', '>= 0.0.4')
  spec.add_dependency('capistrano-patch', '>= 0.0.2')
  spec.add_dependency('capistrano-calendar', '>= 0.1.2')
  spec.add_dependency('rvm-capistrano', '>= 1.2.7')
  spec.add_dependency('erubis')

  spec.version       = Caploy::VERSION
end
