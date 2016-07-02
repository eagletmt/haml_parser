# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Script parser' do
  it 'parses script' do
    ast = expect_single_ast('%span= 1 + 2')
    aggregate_failures do
      expect(ast.oneline_child.script).to eq('1 + 2')
      expect(ast.oneline_child.preserve).to eq(false)
      expect(ast.oneline_child.escape_html).to eq(true)
    end
  end

  it 'parses multi-line script' do
    ast = expect_single_ast(<<HAML)
%span
  = 1 + 2
HAML
    expect(ast.children.size).to eq(1)
    script = ast.children[0]
    aggregate_failures do
      expect(script.script).to eq('1 + 2')
      expect(script.preserve).to eq(false)
      expect(script.escape_html).to eq(true)
    end
  end

  it 'can contain Ruby comment' do
    ast = expect_single_ast('%span= 1 + 2 # comments')
    expect(ast.oneline_child.script).to eq('1 + 2 # comments')
  end

  it 'can contain Ruby comment in multi-line' do
    ast = expect_single_ast(<<HAML)
%span
  = 1 + 2 # comments
HAML
    expect(ast.children[0].script).to eq('1 + 2 # comments')
  end

  it 'can be comment-only' do
    ast = expect_single_ast('= # comment')
    expect(ast.script).to eq('# comment')
  end

  it 'can have children' do
    root = parse(<<HAML)
= 1.times do |i|
  %span= i
%span end
HAML
    expect(root.children.size).to eq(2)
    script, span = root.children
    aggregate_failures do
      expect(script.script).to eq('1.times do |i|')
      expect(script.lineno).to eq(1)
      expect(script.children.size).to eq(1)
      expect(span.tag_name).to eq('span')
      expect(span.lineno).to eq(3)
      expect(span.oneline_child.text).to eq('end')
    end
    span2 = script.children[0]
    aggregate_failures do
      expect(span2.tag_name).to eq('span')
      expect(span2.lineno).to eq(2)
      expect(span2.oneline_child.script).to eq('i')
    end
  end

  it 'parses Ruby multiline' do
    ast = expect_single_ast(<<HAML)
%div
  %span
    = Complex(2,
3)
HAML
    expect(ast.children[0].children[0].script).to eq("Complex(2,\n3)")
  end

  it 'parses == syntax' do
    ast = expect_single_ast('== =#{1+2}hello')
    expect(ast.text).to eq('=#{1+2}hello')
  end

  it 'raises error when there is no Ruby code' do
    expect { parse('%span=') }.to raise_error(HamlParser::Error)
    expect { parse("%span\n  =") }.to raise_error(HamlParser::Error)
  end

  describe '~' do
    it 'parses preserved script' do
      ast = expect_single_ast('~ "hello"')
      aggregate_failures do
        expect(ast.script).to eq('"hello"')
        expect(ast.preserve).to eq(true)
        expect(ast.escape_html).to eq(true)
      end
    end

    it 'parses preserved unescaped script' do
      ast = expect_single_ast('!~ "hello"')
      aggregate_failures do
        expect(ast.script).to eq('"hello"')
        expect(ast.preserve).to eq(true)
        expect(ast.escape_html).to eq(false)
      end
    end

    it 'parses preserved escaped script' do
      ast = expect_single_ast('&~ "hello"')
      aggregate_failures do
        expect(ast.script).to eq('"hello"')
        expect(ast.preserve).to eq(true)
        expect(ast.escape_html).to eq(true)
      end
    end
  end

  describe '&' do
    it 'parses sanitized script' do
      ast = expect_single_ast('&= "hello"')
      aggregate_failures do
        expect(ast.script).to eq('"hello"')
        expect(ast.escape_html).to eq(true)
      end
    end

    it 'ignores single sanitize mark' do
      plain = expect_single_ast('& "hello"')
      expect(plain.text).to eq('"hello"')
      element = expect_single_ast('%span& "hello"')
      expect(element.oneline_child.text).to eq('"hello"')
    end

    it 'parses == syntax' do
      plain = expect_single_ast('&== =hello')
      expect(plain.text).to eq('=hello')
      element = expect_single_ast('%span&== =hello')
      expect(element.oneline_child.text).to eq('=hello')
    end

    it 'raises error when there is no Ruby code' do
      expect { parse('%span&=') }.to raise_error(HamlParser::Error)
      expect { parse("%span\n  &=") }.to raise_error(HamlParser::Error)
    end
  end

  describe '!' do
    it 'parses unescaped script' do
      ast = expect_single_ast('!= "hello"')
      aggregate_failures do
        expect(ast.script).to eq('"hello"')
        expect(ast.escape_html).to eq(false)
      end
    end

    it 'ignores single unescape mark' do
      plain = expect_single_ast('! "hello"')
      expect(plain.text).to eq('"hello"')
      element = expect_single_ast('%span! "hello"')
      expect(element.oneline_child.text).to eq('"hello"')
    end

    it 'parses == syntax' do
      plain = expect_single_ast('!== =hello')
      expect(plain.text).to eq('=hello')
      element = expect_single_ast('%span!== =hello')
      expect(element.oneline_child.text).to eq('=hello')
    end

    it 'raises error when there is no Ruby code' do
      expect { parse('%span!=') }.to raise_error(HamlParser::Error)
      expect { parse("%span\n  !=") }.to raise_error(HamlParser::Error)
    end
  end
end
