# frozen_string_literal: true
require 'bundler/gem_tasks'

task :default => [:spec, :rubocop]

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

desc 'Run all benchmarks'
task :benchmark => ['benchmark:sample', 'benchmark:haml']

namespace :benchmark do
  desc "Run benchmark with haml_parser's sample"
  task :sample do
    sample_haml_path = File.join(__dir__, 'spec', 'fixtures', 'sample.haml')
    sh 'ruby', 'benchmark/parse.rb', sample_haml_path
  end

  desc "Run benchmark with haml's sample"
  task :haml do
    haml_gem = Gem::Specification.find_by_name('haml')
    standard_haml_path = File.join(haml_gem.gem_dir, 'test', 'templates', 'standard.haml')
    sh 'ruby', 'benchmark/parse.rb', standard_haml_path
  end
end
