# frozen_string_literal: true
require 'optparse'
require_relative 'version'

module HamlParser
  class CLI
    def self.start(argv)
      new.start(argv)
    end

    def start(argv)
      formatter = 'pretty'
      OptionParser.new.tap do |parser|
        parser.version = VERSION
        parser.on('-f FORMAT', '--format FORMAT', 'Select formatter') { |v| formatter = v }
      end.parse!(argv)

      require_relative 'parser'
      argv.each do |file|
        format(parse_file(file), formatter)
      end
    end

    def parse_file(file)
      HamlParser::Parser.new(filename: file).call(File.read(file))
    end

    private

    def format(ast, formatter)
      case formatter
      when 'pretty'
        require 'pp'
        pp ast
      when 'pry'
        require 'pry'
        Pry::ColorPrinter.pp ast
      when 'json'
        require 'json'
        puts JSON.generate(ast.to_h)
      else
        abort "Unknown formatter: #{formatter}"
      end
    end
  end
end
