# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test

require 'rubocop/rake_task'
RuboCop::RakeTask.new

namespace :test do
  desc 'Run Rubocop and all tests'
  task full: %i[rubocop:auto_correct test]

  desc 'Run all tests except system tests'
  task quick: :test
end
