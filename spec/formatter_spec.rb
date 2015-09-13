require 'spec_helper'

RSpec.describe 'AST formatter' do
  describe '#to_h' do
    it 'converts to a Hash' do
      root = parse(<<HAML)
!!! 5
%div{hello: 'world'}<
  hoge
  %div.foo#bar> fuga
  :javascript
    (function() {
      alert('hello');
    })();
- if 1.even?

  = 'even'
- else
  -# odd
  odd
/
  %this
    is comment
HAML
      filename = 'spec.haml'
      expect(root.to_h).to eq(
        type: 'root',
        children: [
          {
            type: 'doctype',
            doctype: '5',
            filename: filename,
            lineno: 1,
          },
          {
            type: 'element',
            filename: filename,
            lineno: 2,
            tag_name: 'div',
            static_class: '',
            static_id: '',
            attributes: "hello: 'world'",
            oneline_child: nil,
            self_closing: false,
            nuke_inner_whitespace: true,
            nuke_outer_whitespace: false,
            children: [
              {
                type: 'text',
                filename: filename,
                lineno: 3,
                text: 'hoge',
                escape_html: true,
              },
              {
                type: 'element',
                filename: filename,
                lineno: 4,
                tag_name: 'div',
                static_class: 'foo',
                static_id: 'bar',
                attributes: '',
                oneline_child: {
                  type: 'text',
                  filename: filename,
                  lineno: 4,
                  text: 'fuga',
                  escape_html: true,
                },
                self_closing: false,
                nuke_inner_whitespace: false,
                nuke_outer_whitespace: true,
                children: [],
              },
              {
                type: 'filter',
                filename: filename,
                lineno: 5,
                name: 'javascript',
                texts: [
                  '(function() {',
                  "  alert('hello');",
                  '})();',
                ],
              },
            ],
          },
          {
            type: 'silent_script',
            filename: filename,
            lineno: 9,
            script: 'if 1.even?',
            mid_block_keyword: true,
            children: [
              { type: 'empty', filename: filename, lineno: 10 },
              {
                type: 'script',
                filename: filename,
                lineno: 11,
                script: "'even'",
                escape_html: true,
                preserve: false,
                children: [],
              }
            ],
          },
          {
            type: 'silent_script',
            filename: filename,
            lineno: 12,
            script: 'else',
            mid_block_keyword: false,
            children: [
              {
                type: 'haml_comment',
                filename: filename,
                lineno: 13,
                children: [],
              },
              {
                type: "text",
                filename: filename,
                lineno: 14,
                text: 'odd',
                escape_html: true,
              },
            ],
          },
          {
            type: 'html_comment',
            filename: filename,
            lineno: 15,
            comment: '',
            conditional: '',
            children: [
              {
                type: 'element',
                filename: filename,
                lineno: 16,
                tag_name: 'this',
                static_class: '',
                static_id: '',
                attributes: '',
                oneline_child: nil,
                self_closing: false,
                nuke_inner_whitespace: false,
                nuke_outer_whitespace: false,
                children: [
                  {
                    type: 'text',
                    filename: filename,
                    lineno: 17,
                    text: 'is comment',
                    escape_html: true,
                  },
                ],
              },
            ],
          },
        ],
      )
    end
  end
end
