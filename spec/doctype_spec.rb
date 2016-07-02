# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'doctype parser' do
  it 'parses doctype' do
    ast = expect_single_ast('!!!')
    expect(ast.doctype).to eq('')
  end

  it 'parses XML doctype' do
    ast = expect_single_ast('!!! xml')
    expect(ast.doctype).to eq('xml')
  end

  it 'raises error when doctype has children' do
    expect { parse(<<HAML) }.to raise_error(HamlParser::Error, /nesting within a header command/)
!!!
  hello
HAML
  end
end
