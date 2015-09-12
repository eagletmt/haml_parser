require 'spec_helper'

RSpec.describe 'Filter parser' do
  it 'parses filters' do
    root = parse(<<HAML)
:eagletmt
  hello

  world
%p
HAML
    expect(root.children.size).to eq(2)
    filter = root.children[0]
    aggregate_failures do
      expect(filter.name).to eq('eagletmt')
      expect(filter.texts).to eq(['hello', '', 'world'])
    end
    expect(root.children[1].tag_name).to eq('p')
  end

  it 'ignores filters without texts' do
    ast = expect_single_ast(<<HAML)
:eagletmt
%p
HAML
    aggregate_failures do
      expect(ast.tag_name).to eq('p')
      expect(ast.lineno).to eq(2)
    end
  end

  it 'raises error if invalid filter name is given' do
    expect { parse(':filter with spaces') }.to raise_error(HamlParser::Error)
  end
end
