require 'spec_helper'

RSpec.describe 'Comment parser' do
  it 'parses html comment' do
    ast = expect_single_ast('/ comments')
    aggregate_failures do
      expect(ast.comment).to eq('comments')
      expect(ast.children).to be_empty
    end
  end

  it 'strips spaces' do
    ast = expect_single_ast('/     comments         ')
    aggregate_failures do
      expect(ast.comment).to eq('comments')
    end
  end

  it 'parses structured comment' do
    root = parse(<<HAML)
%span hello
/
  great
%span world
HAML
    expect(root.children.size).to eq(3)
    expect(root.children[0].oneline_child.text).to eq('hello')
    expect(root.children[2].oneline_child.text).to eq('world')
    ast = root.children[1]
    aggregate_failures do
      expect(ast.comment).to eq('')
      expect(ast.children.size).to eq(1)
    end
    expect(ast.children[0].text).to eq('great')
  end

  it 'parses conditional comment' do
    ast = expect_single_ast('/ [if IE] hello')
    aggregate_failures do
      expect(ast.comment).to eq('hello')
      expect(ast.conditional).to eq('if IE')
    end
  end

  it 'parses conditional comment with children' do
    ast = expect_single_ast(<<HAML)
/[if IE]
  %span hello
  world
HAML
    aggregate_failures do
      expect(ast.comment).to eq('')
      expect(ast.conditional).to eq('if IE')
      expect(ast.children.size).to eq(2)
    end
    aggregate_failures do
      expect(ast.children[0].oneline_child.text).to eq('hello')
      expect(ast.children[1].text).to eq('world')
    end
  end

  it 'raises error if conditional comment bracket is unbalanced' do
    expect { parse('/[[if IE]') }.to raise_error(HamlParser::Error)
  end

  it 'raises error if both comment text and children are given' do
    expect { parse(<<HAML) }.to raise_error(HamlParser::Error)
/ hehehe
  %span hello
HAML
  end
end
