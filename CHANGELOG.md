# 0.4.0 (2015-11-21)
- Old attributes and new attributes are no longer merged
    - `Ast::Element#attributes` is left for compatibility

# 0.3.0 (2015-11-16)
- Add support for object reference syntax
- Fix attribute parser for empty braces or parens

# 0.2.0 (2015-11-15)
- Remove `Ast::SilentScript#mid_block_keyword` attribute
- Add `Ast::Script#keyword` and `Ast::SilentScript#keyword` attribute

# 0.1.1 (2015-10-13)
- Fix missing require in CLI

# 0.1.0 (2015-09-13)
- Initial release. Extracted from faml v0.2.16.
    - Fix preserve flag in `~ foobar` syntax
    - Set filename correctly to `Ast::Filter`
    - Remove `Ast::Script#mid_block_keyword` attribute
