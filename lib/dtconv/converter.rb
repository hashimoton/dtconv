# coding: utf-8

require 'time'
require 'dtconv/time_zone'

module Dtconv

  class Converter
    
    
    def change_time_zone(dt, new_offset)
      # TODO accept various formats
      return dt.localtime(new_offset)
    end
    
    
    def round(dt, round_down_unit)
      if round_down_unit =~ /(\d{1,2})([hms])/
        n = $1.to_i
        u = $2
        
        hour = dt.hour
        min = dt.min
        sec = dt.sec
        
        if u == "s"
          sec = sec.div(n)*n
        elsif u == "m"
          min = min.div(n)*n
          sec = 0
        elsif u == "h"
          hour = hour.div(n)*n
          min = 0
          sec = 0
        end
        
        iso8601 = sprintf("%04d-%02d-%02dT%02d:%02d:%02d%s%s", dt.year, dt.month, dt.day, hour, min, sec, ".0", dt.offset)
        
        return Time.iso8601(iso8601)
      else 
        return dt
      end
    end
    
  end # class Converterr
  
end # module Dtconv


# EOF
