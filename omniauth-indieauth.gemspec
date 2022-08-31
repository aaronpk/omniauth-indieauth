# frozen_string_literal: true

require File.expand_path('lib/omniauth-indieauth/version', __dir__)

Gem::Specification.new do |s|
  s.name        = 'omniauth-indieauth'
  s.version     = OmniAuth::IndieAuth::VERSION
  s.authors     = ['Aaron Parecki']
  s.email       = ['aaron@parecki.com']
  s.homepage    = 'https://github.com/aaronpk/omniauth-indieauth'
  s.license     = 'Apache 2.0'
  s.summary     = 'IndieAuth strategy for OmniAuth.'
  s.description = 'An OmniAuth strategy to allow you to authenticate using the IndieAuth protocol'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.executables   = `git ls-files -- exe/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'faraday', '~> 0.9'
  s.add_runtime_dependency 'omniauth', '>= 1.9', '< 3.0'
end
