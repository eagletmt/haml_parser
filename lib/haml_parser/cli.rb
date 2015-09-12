require 'optparse'

module HamlParser
  class CLI
    def self.start(argv)
      new.start(argv)
    end

    def start(argv)
      print_version = false
      OptionParser.new.tap do |parser|
        parser.on('-v', '--version', 'Print version') { print_version = true }
      end.parse!(argv)
      if print_version
        puts "haml_parser #{VERSION}"
        return
      end

      require 'pp'
      require 'haml_parser/parser'
      argv.each do |file|
        pp parse_file(file)
      end
    end

    def parse_file(file)
      HamlParser::Parser.new(filename: file).call(File.read(file))
    end
  end
end
