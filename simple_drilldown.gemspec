$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'simple_drilldown/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'simple_drilldown'
  spec.version     = SimpleDrilldown::VERSION
  spec.authors     = ['Uwe Kubosch']
  spec.email       = ['uwe@datek.no']
  spec.homepage    = 'http://github.com/datekwireless/simple_drilldown'
  spec.summary     = 'Simple data warehouse and drilldown.'
  spec.description = 'simple_drilldown offers a simple way to define axis to filter and group records for analysis.'
  spec.license     = 'MIT'
  spec.required_ruby_version = '>=2.5'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org/'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'caxlsx_rails', '~>0.6'
  spec.add_dependency 'chartkick', '~>4.0'
  spec.add_dependency 'rails', '>=6.1', '<8'

  spec.add_development_dependency 'rubocop', '~>1.1'
  if RUBY_ENGINE == 'jruby'
    spec.add_development_dependency 'activerecord-jdbcsqlite3-adapter'
  else
    spec.add_development_dependency 'sqlite3'
  end
end
