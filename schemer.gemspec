# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "schemer/version"

Gem::Specification.new do |s|
  s.name        = "schemer"
  s.version     = Schemer::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Josep M. Bach"]
  s.email       = ["josep.m.bach@gmail.com"]
  s.homepage    = "http://txus.github.com/schemer"
  s.summary     = %q{A Scheme interpreter in Ruby}
  s.description = %q{A Scheme interpreter in Ruby}

  s.rubyforge_project = "schemer"

  s.add_runtime_dependency 'parslet', '~> 1.2.0'

  s.add_development_dependency 'rspec', '~> 2.5.0'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'rb-fsevent'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
