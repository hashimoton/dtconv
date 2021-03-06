# coding: utf-8

require 'time'

module Dtconv

  class Converter
    
    
    def change_time_zone(dt, new_offset)
      # TODO accept various formats
      return dt.localtime(new_offset)
    end
    
    
  end # class Converterr
  
end # module Dtconv


# EOF
