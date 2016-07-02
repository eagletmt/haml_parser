# frozen_string_literal: true
require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter,
]
SimpleCov.start do
  add_filter File.dirname(__FILE__)
end

require 'haml_parser/parser'

module SpecHelper
  def parse(str)
    HamlParser::Parser.new(filename: 'spec.haml').call(str)
  end

  def expect_single_ast(str)
    root = parse(str)
    expect(root.children.size).to eq(1)
    root.children[0]
  end

  def read_fixture(name)
    File.read(File.join(__dir__, 'fixtures', name))
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.example_status_persistence_file_path = 'spec/examples.txt'

  config.disable_monkey_patching!

  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  if ENV['TRAVIS']
    config.profile_examples = 10
  end

  config.order = :random

  Kernel.srand config.seed

  config.include SpecHelper
end
