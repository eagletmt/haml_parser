require 'spec_helper'

RSpec.describe 'Silent script parser' do
  it 'parses silent script' do
    ast = expect_single_ast(<<HAML)
- 2.times do |i|
  %span= i
HAML
    aggregate_failures do
      expect(ast).to be_a(HamlParser::Ast::SilentScript)
      expect(ast.script).to eq('2.times do |i|')
      expect(ast.mid_block_keyword).to eq(false)
      expect(ast.children.size).to eq(1)
    end
    expect(ast.children[0].oneline_child.script).to eq('i')
  end

  it 'parses if' do
    ast = expect_single_ast(<<HAML)
- if 2.even?
  even
HAML
    aggregate_failures do
      expect(ast.script).to eq('if 2.even?')
      expect(ast.mid_block_keyword).to eq(false)
      expect(ast.children.size).to eq(1)
    end
    expect(ast.children[0].text).to eq('even')
  end

  it 'parses if and else' do
    root = parse(<<HAML)
- if 1.even?
  even
- else
  odd
HAML
    expect(root.children.size).to eq(2)
    if_, else_ = root.children
    aggregate_failures do
      expect(if_.script).to eq('if 1.even?')
      expect(if_.mid_block_keyword).to eq(true)
      expect(if_.children[0].text).to eq('even')
      expect(else_.script).to eq('else')
      expect(else_.mid_block_keyword).to eq(false)
      expect(else_.children[0].text).to eq('odd')
    end
  end
end
