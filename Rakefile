# frozen_string_literal: true

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

APP_RAKEFILE = File.expand_path('test/dummy/Rakefile', __dir__)
load 'rails/tasks/engine.rake'
load 'rails/tasks/statistics.rake'

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task default: :test

require 'rubocop/rake_task'
RuboCop::RakeTask.new

namespace :test do
  desc 'Run Rubocop and all tests'
  task full: %i[rubocop:autocorrect_all test]

  desc 'Run all tests except system tests'
  task quick: :test
end
