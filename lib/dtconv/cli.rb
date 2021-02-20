# coding: utf-8

require 'optparse'
require 'dtconv/parser'

module Dtconv

  class Cli
    OUTPUT_FORMAT = "%Y-%m-%d %H:%M:%S.%3N %:z"
  
    def opt_parse(argv)
      opts = {}
#      input_opts = []
#      while arg = argv.shift
#        if arg.start_with?('-')
#          input_opts.push(arg)
#        else
#         argv.unshift(arg)
#          break
#       end
#      end
      
      
      OptionParser.new do |opt|
        begin
          opt.version = Dtconv::VERSION
          opt.banner += " date time string"
          opt.separator("\nOptions:")
          
          opt.on('-p=INPUT_FORMAT',
            "Format of input string") {|v| opts[:p] = v}
          opt.on('-f=OUTPUT_FORMAT',
            "Format of output string") {|v| opts[:f] = v}
          
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
      
      if input_text.gsub(" ", "").empty?
        input_dt = Time.now
      else
        parser = Dtconv::Parser.new
        if opts[:p]
          input_dt = parser.strptime(input_text, opts[:p])
        else
          input_dt = parser.parse(input_text)
        end
      end
      
      # TODO: Perform timezone conversion / calculation
      output_dt = input_dt
      
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