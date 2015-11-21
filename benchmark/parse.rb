#!/usr/bin/env ruby
# frozen-string-literal: true
require 'benchmark/ips'
require 'haml'
require 'haml_parser/parser'

template = File.read(ARGV[0])
options = Haml::Options.new

Benchmark.ips do |x|
  x.report('Haml::Parser') do
    Haml::Parser.new(template, options).parse
  end

  x.report('HamlParser::Parser') do
    HamlParser::Parser.new.call(template)
  end

  x.compare!
end
