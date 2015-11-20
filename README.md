# HamlParser
[![Gem Version](https://badge.fury.io/rb/haml_parser.svg)](http://badge.fury.io/rb/haml_parser)
[![Build Status](https://travis-ci.org/eagletmt/haml_parser.svg?branch=master)](https://travis-ci.org/eagletmt/haml_parser)
[![Coverage Status](https://coveralls.io/repos/eagletmt/haml_parser/badge.svg?branch=master&service=github)](https://coveralls.io/github/eagletmt/haml_parser?branch=master)
[![Code Climate](https://codeclimate.com/github/eagletmt/haml_parser/badges/gpa.svg)](https://codeclimate.com/github/eagletmt/haml_parser)

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/haml_parser`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'haml_parser'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install haml_parser

## Usage

```ruby
parser = HamlParser::Parser.new(filename: 'input.haml')
ast = parser.call(File.read('input.haml'))
```

Simple CLI interface is also available.

```
% cat input.haml
%p hello world
% haml_parser input.haml
#<struct HamlParser::Ast::Root
 children=
  [#<struct HamlParser::Ast::Element
    children=[],
    tag_name="p",
    static_class="",
    static_id="",
    old_attributes=nil,
    new_attributes=nil,
    oneline_child=
     #<struct HamlParser::Ast::Text
      text="hello world",
      escape_html=true,
      filename="input.haml",
      lineno=1>,
    self_closing=false,
    nuke_inner_whitespace=false,
    nuke_outer_whitespace=false,
    object_ref=nil,
    filename="input.haml",
    lineno=1>]>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eagletmt/haml_parser.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
