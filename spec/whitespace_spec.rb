require 'spec_helper'

RSpec.describe 'Element with > or <' do
  it 'parses nuke-outer-whitespace (>)' do
    ast = expect_single_ast('%span> hello')
    aggregate_failures do
      expect(ast.tag_name).to eq('span')
      expect(ast.nuke_outer_whitespace).to eq(true)
      expect(ast.nuke_inner_whitespace).to eq(false)
      expect(ast.oneline_child.text).to eq('hello')
    end
  end

  it 'parses nuke-inner-whitespace (>)' do
    ast = expect_single_ast(<<HAML)
%blockquote<
  %div
    hello
HAML
    aggregate_failures do
      expect(ast.tag_name).to eq('blockquote')
      expect(ast.nuke_outer_whitespace).to eq(false)
      expect(ast.nuke_inner_whitespace).to eq(true)
      expect(ast.children[0].children[0].text).to eq('hello')
    end
  end

  it 'parses ><' do
    ast = expect_single_ast(<<HAML)
%pre><
  hello
HAML
    aggregate_failures do
      expect(ast.tag_name).to eq('pre')
      expect(ast.nuke_outer_whitespace).to eq(true)
      expect(ast.nuke_inner_whitespace).to eq(true)
      expect(ast.children[0].text).to eq('hello')
    end
  end
end
