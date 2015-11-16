require 'spec_helper'

RSpec.describe 'HTML-style attribute parser' do
  it 'parses simple values' do
    ast = expect_single_ast('%span(foo=1 bar=3) hello')
    aggregate_failures do
      expect(ast.tag_name).to eq('span')
      expect(ast.attributes).to eq('"foo" => 1,"bar" => 3,')
      expect(ast.oneline_child.text).to eq('hello')
    end
  end

  it 'parses variables' do
    ast = expect_single_ast('%span(foo=foo bar=3) hello')
    aggregate_failures do
      expect(ast.attributes).to eq('"foo" => foo,"bar" => 3,')
    end
  end

  it 'parses attributes with old syntax' do
    ast = expect_single_ast('%span(foo=foo){bar: 3} hello')
    aggregate_failures do
      expect(ast.attributes).to eq('bar: 3, "foo" => foo,')
      expect(ast.oneline_child.text).to eq('hello')
    end
  end

  it 'parses HTML-style multiline attribute list' do
    ast = expect_single_ast(<<HAML)
%span(foo=1

bar=3) hello
HAML
    aggregate_failures do
      expect(ast.attributes).to eq(%Q{"foo" => 1,\n\n"bar" => 3,})
    end
  end

  it "doesn't parse extra parens" do
    ast = expect_single_ast('%span(foo=1)(bar=3) hello')
    aggregate_failures do
      expect(ast.attributes).to eq('"foo" => 1,')
      expect(ast.oneline_child.text).to eq('(bar=3) hello')
    end
  end

  it 'parses empty parens' do
    ast = expect_single_ast('%span()(bar=3) hello')
    aggregate_failures do
      expect(ast.attributes).to eq('')
      expect(ast.oneline_child.text).to eq('(bar=3) hello')
    end
  end

  it "doesn't skip spaces before attribute list" do
    ast = expect_single_ast('%span (hello)')
    aggregate_failures do
      expect(ast.tag_name).to eq('span')
      expect(ast.attributes).to eq('')
      expect(ast.oneline_child.text).to eq('(hello)')
    end
  end

  it 'parses single-quoted value' do
    ast = expect_single_ast('%span(foo=1 bar="baz") hello')
    aggregate_failures do
      expect(ast.attributes).to eq('"foo" => 1,"bar" => "baz",')
    end
  end

  it 'parses double-quoted value' do
    ast = expect_single_ast("%span(foo=1 bar='baz') hello")
    aggregate_failures do
      expect(ast.attributes).to eq('"foo" => 1,"bar" => "baz",')
    end
  end

  it 'parses key-only attribute' do
    ast = expect_single_ast('%span(foo bar=1) hello')
    aggregate_failures do
      expect(ast.attributes).to eq('"foo" => true,"bar" => 1,')
    end
  end

  it 'parses string interpolation in single-quote' do
    ast = expect_single_ast('%span(foo=1 bar="baz#{1 + 2}") hello')
    aggregate_failures do
      expect(ast.attributes).to eq('"foo" => 1,"bar" => "baz#{1 + 2}",')
    end
  end

  it 'parses string interpolation in double-quote' do
    ast = expect_single_ast('%span(foo=1 bar="baz#{1 + 2}") hello')
    aggregate_failures do
      expect(ast.attributes).to eq('"foo" => 1,"bar" => "baz#{1 + 2}",')
    end
  end

  it 'parses escaped single-quote' do
    ast = expect_single_ast(%q|%span(foo=1 bar='ba\'z') hello|)
    aggregate_failures do
      expect(ast.attributes).to eq(%q|"foo" => 1,"bar" => "ba\'z",|)
    end
  end

  it 'parses escaped double-quote' do
    ast = expect_single_ast('%span(foo=1 bar="ba\"z") hello')
    aggregate_failures do
      expect(ast.attributes).to eq('"foo" => 1,"bar" => "ba\"z",')
    end
  end

  it 'raises error when attributes list is unterminated' do
    expect { parse('%span(foo=1 bar=2') }.to raise_error(HamlParser::Error)
  end

  it 'raises error when key is not alnum' do
    expect { parse('%span(foo=1 3.14=3) hello') }.to raise_error(HamlParser::Error)
  end

  it 'raises error when value is missing' do
    expect { parse('%span(foo=1 bar=) hello') }.to raise_error(HamlParser::Error)
  end

  it 'raises error when quote is unterminated' do
    expect { parse('%span(foo=1 bar="baz) hello') }.to raise_error(HamlParser::Error)
  end

  it 'raises error when string interpolation is unterminated' do
    expect { parse('%span(foo=1 bar="ba#{1") hello') }.to raise_error(HamlParser::Error)
  end
end
