# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'asmodai/version'

Gem::Specification.new do |s|
  s.name        = "asmodai"
  s.version     = Asmodai::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Sebastian Morawietz"]
  s.email       = []
  s.homepage    = "https://github.com/flitzwald/asmodai"
  s.summary     = "A simple daemon generator"
  s.description = "A simple daemon generator"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "asmodai"

  s.add_development_dependency "bundler", ">= 1.0.0.rc.5"
  s.add_dependency 'thor', ">=0.14.6"
  s.add_dependency 'activesupport', ">=3.0.3"
  
  s.files        = (`git ls-files`.split("\n")+Dir['lib/asmodai/generator/templates/*']).uniq
  s.executables  = ['asmodai']
  s.require_path = 'lib'
end
