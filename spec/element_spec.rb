# frozen-string-literal: true
require 'spec_helper'

RSpec.describe 'Element parser' do
  it 'parses one-line element' do
    ast = expect_single_ast('%span hello')
    aggregate_failures do
      expect(ast.tag_name).to eq('span')
      expect(ast.oneline_child.text).to eq('hello')
      expect(ast.children).to be_empty
    end
  end

  it 'parses multi-line element' do
    ast = expect_single_ast(<<HAML)
%span
  hello
HAML
    aggregate_failures do
      expect(ast.tag_name).to eq('span')
      expect(ast.lineno).to eq(1)
      expect(ast.oneline_child).to be_nil
      expect(ast.children.size).to eq(1)
    end
    aggregate_failures do
      expect(ast.children[0].text).to eq('hello')
      expect(ast.children[0].lineno).to eq(2)
    end
  end

  it 'parses nested elements' do
    ast = expect_single_ast(<<HAML)
%span
  %b
    hello
  %i
    %small world
HAML
    aggregate_failures do
      expect(ast.tag_name).to eq('span')
      expect(ast.oneline_child).to be_nil
      expect(ast.children.size).to eq(2)
    end

    b = ast.children[0]
    aggregate_failures do
      expect(b.tag_name).to eq('b')
      expect(b.lineno).to eq(2)
      expect(b.oneline_child).to be_nil
      expect(b.children.size).to eq(1)
    end
    aggregate_failures do
      expect(b.children[0].text).to eq('hello')
      expect(b.children[0].lineno).to eq(3)
    end

    i = ast.children[1]
    aggregate_failures do
      expect(i.tag_name).to eq('i')
      expect(i.lineno).to eq(4)
      expect(i.oneline_child).to be_nil
      expect(i.children.size).to eq(1)
    end

    small = i.children[0]
    aggregate_failures do
      expect(small.tag_name).to eq('small')
      expect(small.lineno).to eq(5)
      expect(small.oneline_child.text).to eq('world')
      expect(small.children).to be_empty
    end
  end

  it 'parses multi-line texts' do
    ast = expect_single_ast(<<HAML)
%span
  %b
    hello
    world
HAML
    expect(ast.children.size).to eq(1)
    b = ast.children[0]
    expect(b.children.size).to eq(2)
    aggregate_failures do
      expect(b.children[0].text).to eq('hello')
      expect(b.children[0].lineno).to eq(3)
      expect(b.children[1].text).to eq('world')
      expect(b.children[1].lineno).to eq(4)
    end
  end

  it 'parses empty lines' do
    ast = expect_single_ast(<<HAML)
%span

  %b

    hello

HAML
    expect(ast.children.size).to eq(2)
    aggregate_failures do
      expect(ast.children[0]).to be_a(HamlParser::Ast::Empty)
      expect(ast.children[0].lineno).to eq(2)
    end
    b = ast.children[1]
    aggregate_failures do
      expect(b.lineno).to eq(3)
      expect(b.children.size).to eq(3)
    end
    aggregate_failures do
      expect(b.children[0]).to be_a(HamlParser::Ast::Empty)
      expect(b.children[0].lineno).to eq(4)
      expect(b.children[1].text).to eq('hello')
      expect(b.children[1].lineno).to eq(5)
      expect(b.children[2]).to be_a(HamlParser::Ast::Empty)
      expect(b.children[2].lineno).to eq(6)
    end
  end

  context 'with invalid tag name' do
    it 'raises error' do
      expect { parse('%.foo') }.to raise_error(HamlParser::Error)
    end
  end

  it 'parses Ruby multiline' do
    ast = expect_single_ast(<<HAML)
%div
  %span= Complex(2,
3)
HAML

    expect(ast.children.size).to eq(1)
    span = ast.children[0]
    aggregate_failures do
      expect(span.oneline_child.script).to eq("Complex(2,\n3)")
      expect(span.oneline_child.lineno).to eq(2)
    end
  end

  it 'parses self-closing tag' do
    ast = expect_single_ast('%p/')
    aggregate_failures do
      expect(ast.tag_name).to eq('p')
      expect(ast.self_closing).to eq(true)
    end
  end

  it 'parses == syntax' do
    ast = expect_single_ast('%p== =#{1+2}hello')
    expect(ast.oneline_child.text).to eq('=#{1+2}hello')
  end

  it 'raises error if self-closing tag have text' do
    expect { parse('%p/ hello') }.to raise_error(HamlParser::Error)
  end

  it 'raises error if self-closing tag have children' do
    expect { parse(<<HAML) }.to raise_error(HamlParser::Error)
%p/
  hello
HAML
  end
end
