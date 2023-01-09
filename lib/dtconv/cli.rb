# coding: utf-8

require 'optparse'
require 'dtconv/parser'
require 'dtconv/converter'
require 'dtconv/time_zone'

module Dtconv

  class Cli
    OUTPUT_FORMAT = "%Y-%m-%d %H:%M:%S.%3N %:z"
  
    def opt_parse(argv)
      opts = {}
      
      OptionParser.new do |opt|
        begin
          opt.version = Dtconv::VERSION
          opt.banner += " date time string"
          opt.separator("\nOptions:")
          
          opt.on('-p=INPUT_FORMAT',
            "Format of input string, see https://docs.ruby-lang.org/ja/latest/method/Date/s/_strptime.html") {|v| opts[:p] = v}
          opt.on('-f=OUTPUT_FORMAT',
            "Format of output string, see https://docs.ruby-lang.org/ja/latest/method/Date/s/_strptime.html") {|v| opts[:f] = v}
          
          opt.on('-o=OUTPUT_TIMEZONE',
            "Timezone or UTC offset for output") {|v| opts[:o] = v}
          opt.on('-r=ROUND_DOWN_UNIT',
            "Round down unit like 1s, 5m, 3h, etc.") {|v| opts[:r] = v}
          
          opt.order!(argv)
        rescue => e
          $stderr.puts "ERROR: #{e}.\n#{opt}"
          exit 1
        end
      end
      
      return opts
    end
    
    def main(argv)
      opts = opt_parse(argv)
      input_text = argv.join(" ")
      parser = Dtconv::Parser.new
      converter = Dtconv::Converter.new
      
      if input_text.gsub(" ", "").empty?
        input_dt = Time.now
      else
        if opts[:p]
          input_dt = parser.strptime(input_text, opts[:p])
        else
          input_dt = parser.parse(input_text)
        end
      end
      
      input_dt = converter.round(input_dt, opts[:r])
      
      output_offset = opts[:o]
      if output_offset.nil? || output_offset.empty?
        output_dt = input_dt
      else
        offset, _ = parser.extract_offset(output_offset)
        if offset.empty?
          offset, _ = Dtconv::TimeZone.zone2offset(output_offset.upcase)
        end
        
        if offset.empty?
          output_dt = input_dt
        else
          output_dt = converter.change_time_zone(input_dt, offset)
        end
      end
      
      if opts[:f]
        output_text = output_dt.strftime(opts[:f])
      else
        # Need a formatter?
        output_text = output_dt.strftime(OUTPUT_FORMAT)
      end
      
      puts output_text
      
    end

  end # class Cli
  
end # module Dtconv


# EOF