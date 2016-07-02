# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Haml comment parser' do
  it 'parses Haml comment' do
    ast = expect_single_ast(<<HAML)
%div
  %p hello
  -# this
      should
    not
      be rendered
  %p world
HAML
    expect(ast.children.size).to eq(3)
    aggregate_failures do
      expect(ast.children[0].tag_name).to eq('p')
      expect(ast.children[1]).to be_a(HamlParser::Ast::HamlComment)
      expect(ast.children[2].tag_name).to eq('p')
    end
    comment = ast.children[1]
    expect(comment.children.size).to eq(3)
    aggregate_failures do
      expect(comment.children[0].text).to eq('should')
      expect(comment.children[0].lineno).to eq(4)
      expect(comment.children[1].text).to eq('not')
      expect(comment.children[1].lineno).to eq(5)
      expect(comment.children[2].text).to eq('be rendered')
      expect(comment.children[2].lineno).to eq(6)
    end
  end

  it 'parses empty comment' do
    ast = expect_single_ast(<<HAML)
%div
  %p hello
  -#
  %p world
HAML
    expect(ast.children[1]).to be_a(HamlParser::Ast::HamlComment)
    expect(ast.children[1].children).to be_empty
  end
end
