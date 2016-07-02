# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Plain parser' do
  it 'parses literally when prefixed with backslash' do
    ast = expect_single_ast('\= @title')
    expect(ast.text).to eq('= @title')
  end

  it 'raises error when text has children' do
    expect { parse(<<HAML) }.to raise_error(HamlParser::Error, /nesting within plain text/)
hello
  world
HAML
  end
end
