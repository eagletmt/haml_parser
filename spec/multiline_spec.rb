require 'spec_helper'

RSpec.describe 'Multiline rendering', type: :render do
  it 'handles multiline syntax' do
    ast = expect_single_ast(<<HAML)
%p
  = "foo " + |
    "bar " + |   
    "baz"               |
  = "quux"
HAML
    expect(ast.children.size).to eq(4)
    foo, empty1, empty2, quux = ast.children
    aggregate_failures do
      expect(foo.script).to eq('"foo " + "bar " + "baz"               ')
      expect(empty1).to be_a(HamlParser::Ast::Empty)
      expect(empty2).to be_a(HamlParser::Ast::Empty)
      expect(quux.script).to eq('"quux"')
      expect(quux.lineno).to eq(5)
    end
  end

  it 'handles multiline with non-script line' do
    ast = expect_single_ast(<<HAML)
%p
  foo |  
  bar
HAML
    expect(ast.children.size).to eq(2)
    foo, bar = ast.children
    aggregate_failures do
      expect(foo.text).to eq('foo ')
      expect(foo.lineno).to eq(2)
      expect(bar.text).to eq('bar')
      expect(bar.lineno).to eq(3)
    end
  end

  it 'handles multiline at the end of template' do
    ast = expect_single_ast(<<HAML)
%p
  foo  |
bar |
  baz |
HAML
    expect(ast.children.size).to eq(3)
    text, empty1, empty2 = ast.children
    aggregate_failures do
      expect(text.text).to eq('foo  bar baz ')
      expect(empty1).to be_a(HamlParser::Ast::Empty)
      expect(empty2).to be_a(HamlParser::Ast::Empty)
    end
  end

  it 'is not multiline' do
    ast = expect_single_ast(<<HAML)
%div
  hello
  |
  world
HAML
    expect(ast.children.size).to eq(3)
  end

  it 'can be used in attribute list' do
    ast = expect_single_ast(<<HAML)
%div{foo: 1, |
  bar: 2}
HAML
    expect(ast.attributes).to eq("foo: 1, \n  bar: 2")
  end

  it "isn't enabled in filter" do
    ast = expect_single_ast(<<HAML)
:javascript
  hello |
  world |
HAML
    expect(ast.texts).to eq(['hello |', 'world |'])
  end
end
