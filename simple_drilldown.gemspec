# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_drilldown/version'

Gem::Specification.new do |spec|
  spec.name          = 'simple_drilldown'
  spec.version       = SimpleDrilldown::VERSION
  spec.authors       = ['Uwe Kubosch']
  spec.email         = %w(uwe@kubosch.no)
  spec.summary       = %q{Simple data warehouse and drilldown.}
  spec.description   = %q{simple_drilldown offers a simple way to define axis to filter and group records for analysis.}
  spec.homepage      = 'http://github.com/datekwireless/simple_drilldown'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_dependency 'rails'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
