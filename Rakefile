# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

require "steep/rake_task"
Steep::RakeTask.new do |t|
  t.check.severity_level = :error
  t.watch.verbose
end

task default: %i[spec rubocop steep]
