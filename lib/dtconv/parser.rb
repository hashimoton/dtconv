# coding: utf-8

require 'optparse'
require 'time'

module Dtconv

  class Parser
    
    def strptime(input_text, format)
      Time.strptime(input_text, format)
    end
    
    def parse(input_text)
      Time.parse(input_text)
    end
    
  end # class Parser
  
end # module Dtconv


# EOF
