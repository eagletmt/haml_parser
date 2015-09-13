require 'optparse'

module HamlParser
  class CLI
    def self.start(argv)
      new.start(argv)
    end

    def start(argv)
      formatter = 'pretty'
      print_version = false
      OptionParser.new.tap do |parser|
        parser.on('-f FORMAT', '--format FORMAT', 'Select formatter') { |v| formatter = v }
        parser.on('-v', '--version', 'Print version') { print_version = true }
      end.parse!(argv)
      if print_version
        puts "haml_parser #{VERSION}"
        return
      end

      require 'haml_parser/parser'
      argv.each do |file|
        format(parse_file(file), formatter)
      end
    end

    def parse_file(file)
      HamlParser::Parser.new(filename: file).call(File.read(file))
    end

    private

    def format(obj, formatter)
      case formatter
      when 'pretty'
        require 'pp'
        pp obj
      when 'pry'
        require 'pry'
        Pry::ColorPrinter.pp obj
      else
        abort "Unknown formatter: #{formatter}"
      end
    end
  end
end
