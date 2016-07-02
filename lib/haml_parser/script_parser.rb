# frozen_string_literal: true
require_relative 'ast'
require_relative 'error'
require_relative 'ruby_multiline'

module HamlParser
  class ScriptParser
    def initialize(line_parser)
      @line_parser = line_parser
    end

    def parse(text)
      case text[0]
      when '=', '~'
        parse_script(text)
      when '&'
        parse_sanitized(text)
      when '!'
        parse_unescape(text)
      else
        parse_text(text)
      end
    end

    private

    def parse_script(text)
      if text[1] == '='
        create_node(Ast::Text) { |t| t.text = text[2..-1].strip }
      else
        node = create_node(Ast::Script)
        script = text[1..-1].lstrip
        if script.empty?
          syntax_error!('No Ruby code to evaluate')
        end
        node.script = [script, *RubyMultiline.read(@line_parser, script)].join("\n")
        node.preserve = text[0] == '~'
        node
      end
    end

    def parse_sanitized(text)
      if text.start_with?('&==')
        create_node(Ast::Text) { |t| t.text = text[3..-1].lstrip }
      elsif text[1] == '=' || text[1] == '~'
        node = create_node(Ast::Script)
        script = text[2..-1].lstrip
        if script.empty?
          syntax_error!('No Ruby code to evaluate')
        end
        node.script = [script, *RubyMultiline.read(@line_parser, script)].join("\n")
        node.preserve = text[1] == '~'
        node
      else
        create_node(Ast::Text) { |t| t.text = text[1..-1].strip }
      end
    end

    def parse_unescape(text)
      if text.start_with?('!==')
        create_node(Ast::Text) do |t|
          t.text = text[3..-1].lstrip
          t.escape_html = false
        end
      elsif text[1] == '=' || text[1] == '~'
        node = create_node(Ast::Script)
        node.escape_html = false
        script = text[2..-1].lstrip
        if script.empty?
          syntax_error!('No Ruby code to evaluate')
        end
        node.script = [script, *RubyMultiline.read(@line_parser, script)].join("\n")
        node.preserve = text[1] == '~'
        node
      else
        create_node(Ast::Text) do |t|
          t.text = text[1..-1].lstrip
          t.escape_html = false
        end
      end
    end

    def parse_text(text)
      text = text.lstrip
      if text.empty?
        nil
      else
        create_node(Ast::Text) { |t| t.text = text }
      end
    end

    def syntax_error!(message)
      raise Error.new(message, @line_parser.lineno)
    end

    def create_node(klass, &block)
      klass.new.tap do |node|
        node.filename = @line_parser.filename
        node.lineno = @line_parser.lineno
        if block
          block.call(node)
        end
      end
    end
  end
end
