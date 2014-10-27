# encoding: UTF-8
require File.expand_path('../lib/omniauth-indieauth/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'omniauth-indieauth'
  s.version     = OmniAuth::IndieAuth::VERSION
  s.authors     = ['Aaron Parecki']
  s.email       = ['aaron@parecki.com']
  s.homepage    = 'https://github.com/aaronpk/omniauth-indieauth'
  s.license     = 'Apache 2.0'
  s.summary     = 'IndieAuth adapter for OmniAuth.'
  s.description = 'An OmniAuth strategy to allow you to authenticate '\
                  'using IndieAuth.com.'

  s.rubyforge_project = 'omniauth-indieauth'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'omniauth', '~> 1.0'
  s.add_runtime_dependency 'faraday', '~> 0.9.0'
end
