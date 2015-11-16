require 'spec_helper'

RSpec.describe 'Attribute parser' do
  it 'parses attributes' do
    ast = expect_single_ast('%span{class: "x"} hello')
    expect(ast).to be_a(HamlParser::Ast::Element)
    aggregate_failures do
      expect(ast.tag_name).to eq('span')
      expect(ast.attributes).to eq('class: "x"')
      expect(ast.lineno).to eq(1)
      expect(ast.children).to be_empty
      expect(ast.oneline_child.text).to eq('hello')
      expect(ast.oneline_child.lineno).to eq(1)
      expect(ast.object_ref).to be_nil
    end
  end

  it "doesn't parse extra brace" do
    ast = expect_single_ast('%span{foo: 1}{bar: 2}')
    aggregate_failures do
      expect(ast.tag_name).to eq('span')
      expect(ast.attributes).to eq('foo: 1')
      expect(ast.oneline_child.text).to eq('{bar: 2}')
    end
  end

  it "doesn't skip spaces before attribute list" do
    ast = expect_single_ast('%span {hello}')
    aggregate_failures do
      expect(ast.tag_name).to eq('span')
      expect(ast.attributes).to eq('')
      expect(ast.oneline_child.text).to eq('{hello}')
    end
  end

  describe 'object reference' do
    it 'parses object ref' do
      ast = expect_single_ast('%span[foo]{class: "x"} hello')
      aggregate_failures do
        expect(ast.tag_name).to eq('span')
        expect(ast.attributes).to eq('class: "x"')
        expect(ast.object_ref).to eq('foo')
        expect(ast.oneline_child.text).to eq('hello')
      end
    end

    it 'parses only one object ref' do
      ast = expect_single_ast('%span[foo]{class: "x"}[bar] hello')
      aggregate_failures do
        expect(ast.tag_name).to eq('span')
        expect(ast.attributes).to eq('class: "x"')
        expect(ast.object_ref).to eq('foo')
        expect(ast.oneline_child.text).to eq('[bar] hello')
      end
    end

    it 'raises error for unmatched brackets' do
      expect { parse('%span[foo hello') }.to raise_error(HamlParser::Error)
    end
  end

  describe 'static class' do
    it 'parses' do
      ast = expect_single_ast('%span.foo.bar .baz')
      aggregate_failures do
        expect(ast.tag_name).to eq('span')
        expect(ast.attributes).to eq('')
        expect(ast.static_class).to eq('foo bar')
        expect(ast.children).to be_empty
        expect(ast.oneline_child.text).to eq('.baz')
      end
    end

    it 'parses empty tag name' do
      ast = expect_single_ast('.foo.bar .baz')
      aggregate_failures do
        expect(ast.tag_name).to eq('div')
        expect(ast.attributes).to eq('')
        expect(ast.static_class).to eq('foo bar')
        expect(ast.children).to be_empty
        expect(ast.oneline_child.text).to eq('.baz')
      end
    end

    context 'with invalid classes' do
      it 'raises error' do
        expect { parse('%span. hello') }.to raise_error(HamlParser::Error)
        expect { parse('%span.{foo: "bar"} hello') }.to raise_error(HamlParser::Error)
      end
    end
  end

  describe 'static id' do
    it 'parses' do
      ast = expect_single_ast('%span#foo #bar')
      aggregate_failures do
        expect(ast.tag_name).to eq('span')
        expect(ast.attributes).to eq('')
        expect(ast.static_id).to eq('foo')
        expect(ast.children).to be_empty
        expect(ast.oneline_child.text).to eq('#bar')
      end
    end

    it 'parses empty tag name' do
      ast = expect_single_ast('#foo #bar')
      aggregate_failures do
        expect(ast.tag_name).to eq('div')
        expect(ast.attributes).to eq('')
        expect(ast.static_id).to eq('foo')
        expect(ast.children).to be_empty
        expect(ast.oneline_child.text).to eq('#bar')
      end
    end

    it 'ignores leading static ids' do
      ast = expect_single_ast('#foo#bar#baz')
      aggregate_failures do
        expect(ast.attributes).to eq('')
        expect(ast.static_id).to eq('baz')
        expect(ast.children).to be_empty
        expect(ast.oneline_child).to be_nil
      end
    end

    it 'ignores invalid static id' do
      ast = expect_single_ast('#{1 + 2}')
      expect(ast).to_not be_a(HamlParser::Ast::Element)
      aggregate_failures do
        expect(ast.text).to eq('#{1 + 2}')
      end
    end

    context 'with invalid ids' do
      it 'raises error' do
        expect { parse('%span# hello') }.to raise_error(HamlParser::Error)
        expect { parse('%span#{foo: "bar"} hello') }.to raise_error(HamlParser::Error)
      end
    end
  end

  context 'with unmatched brace' do
    it 'raises error' do
      expect { parse('%span{foo hello') }.to raise_error(HamlParser::Error)
    end

    it 'tries to parse next lines' do
      ast = expect_single_ast(<<HAML)
%span{foo: 1,
bar: 2} hello
HAML
      aggregate_failures do
        expect(ast.attributes).to eq("foo: 1,\nbar: 2")
        expect(ast.oneline_child.text).to eq('hello')
      end
    end

    it "doesn't try to parse next lines without trailing comma" do
      expect { parse(<<HAML) }.to raise_error(HamlParser::Error)
%span{foo: 1
, bar: 2} hello
HAML
    end

    it 'parses attributes with braces' do
      ast = expect_single_ast(<<HAML)
%span{data: {foo: 1,
  bar: 2}}
  %span hello
HAML
      aggregate_failures do
        expect(ast.attributes).to eq("data: {foo: 1,\n  bar: 2}")
        expect(ast.oneline_child).to be_nil
      end
      expect(ast.children.size).to eq(1)
      child = ast.children[0]
      aggregate_failures do
        expect(child.tag_name).to eq('span')
        expect(child.oneline_child.text).to eq('hello')
      end
    end
  end
end
