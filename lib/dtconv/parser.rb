# coding: utf-8

require 'optparse'
require 'time'

module Dtconv

  # cf. https://en.wikipedia.org/wiki/Date_format_by_country
  class Parser
    
    MONTHS_SHORT = ['JAN', 'FEB', 'MAR' , 'APR' , 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC']
    MONTHS_LONG = ['JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE','JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER']
    MONTHS = [MONTHS_SHORT, MONTHS_LONG].flatten
    MONTHS_LIST = MONTHS.join('|')
    REGEX_YMD = /(\d+)\W{,2}(\d+)\W{,2}(\d+)/
    REGEX_YMOND = /(\d+)\W{,2}(#{MONTHS_LIST})\W{,2}(\d+)/
    REGEX_MONDY = /(#{MONTHS_LIST})\W{,2}([0-9]+)\W+([0-9]+)/
    REGEX_S8 = /(\d{8})/
    
    
    def extract_date(text_no_time)
    
      dt_text = text_no_time
      
      if REGEX_YMD.match(dt_text)
        n1 = $1.to_i
        n2 = $2.to_i
        n3 = $3.to_i
        
        if 1 <= n2 && n2 <= 12 && 1 <= n3 && n3 <= 31
          return [n1, n2, n3]
        elsif 1 <= n1 && n1 <= 12 && 1 <= n2 && n2 <= 31
          return [n3, n1, n2]
        elsif 1 <= n1 && n1 <= 31 && 1 <= n2 && n2 <= 12
          return [n3, n2, n1]
        elsif 1 <= n2 && n2 < 31 && 1 <= n3 && n3 <= 12
          return [n1, n3, n2]
        end
      end
      
      if REGEX_YMOND.match(dt_text)
        n1 = $1.to_i
        n2 = (MONTHS.index($2) % 12) + 1
        n3 = $3.to_i
        
        if 1 <= n3 && n3 <= 31
          return [n1, n2, n3]
        elsif 1<= n1 && n1 < 31
          return [n3, n2, n1]
        end
      end
      
      if REGEX_MONDY.match(dt_text)
        n1 = (MONTHS.index($1) % 12) + 1
        n2 = $2.to_i
        n3 = $3.to_i
        
        if 1 <= n2 && n2 <= 31
          return [n3, n1, n2]
        elsif 1<= n3 && n3 < 31
          return [n2, n1, n3]
        end
      end
      
      if REGEX_S8.match(dt_text)
        if $1.size == 8
          n1 = $1[0,4].to_i
          n2 = $1[4,2].to_i
          n3 = $1[6,2].to_i
          if 1 <= n2 && n2 <= 12 && 1 <= n3 && n3 <= 31
            return [n1, n2, n3]
          end
        end
      end
      
      return [0, 0, 0, ""]
    end
    
    
    ZONE_OFFSETS = {
      "UTC" => "+00:00",
      "IST" => "+05:30",
      "JST" => "+09:00"
    }

    def zone2offset(time_zone)
      return ZONE_OFFSETS[time_zone] || ""
    end

    REGEX_S6 = /(\d{8})/

    def normalize(text)
      normalized = ""
      if !text.nil?
        normalized = text.tr("年月日時分秒", "// :: ").gsub(/\s+/, " ").upcase
        normalized = normalized.sub("A.M.", "AM").sub("P.M.", "PM")
      end
      
      return normalized
    end

    def extract_offset(text)
      offset = ""

      if text =~ /([+-])([0-9]{3,4})([^0-9]|$)/
        offset_raw = "#{$1}#{$2}"
        offset4 = $2.rjust(4, '0')
        offset = "#{$1}#{offset4[0, 2]}:#{offset4[2, 2]}"
        return [offset, text.sub(offset_raw, " ")]
      end

      if text =~ /([+-])([0-9]{1,2}):([0-9]{2})([^0-9]|$)/
        offset_raw = "#{$1}#{$2}:#{$3}"
        offset_hour = $2.rjust(2, '0')
        offset = "#{$1}#{offset_hour}:#{$3}"
        return [offset, text.sub(offset_raw, " ")]
      end

      return [offset, text]
    end

    REGEX_TIME = /([0-9]{1,2}):([0-9]{1,2}):?([0-9]{1,2})?(\.[0-9]+)?[^0-9]?(AM|PM)?[ ]?([A-Z]{1,4})?/

    def extract_time(text_no_offset)
      text_no_time = text_no_offset.sub(REGEX_TIME, " ")
      
      if !$1.nil?
        h = $1.to_i
        m = $2.to_i
        if !$3.nil?
          s = $3.to_i
        else
          s = 0
        end
        
        decimal = $4 || ""
        
        ampm = $5 || ""
        if ampm == "PM"
          h = (h + 12) % 24
        end
        
        z = $6
        if !z.nil?
          offset = zone2offset(z)
        end
        
        return [h, m, s, decimal, offset, text_no_time]
      end
      
      return [0, 0, 0, "", "", text_no_time]
    end
    
    
    def parse(text)
      offset, text_no_offset = extract_offset(normalize(text))
      hour, minute, second, decimal, offset_tz, text_no_time = extract_time(text_no_offset)
      
      if offset.nil? || offset.empty?
        offset = offset_tz
      end
      
      year, month, day, rest = extract_date(text_no_time)
      # Epoch? (sec/msec)
      # epoch = extract_epoch(rest)
      
      # dt = {year: year, month: month, day: day, hour: hour, minute: minute, second: second,
      #   decimal: decimal, offset:offset, rest: rest}
      if year == 0 || month == 0 || day == 0
        time_only = "%02d:%02d:%02d%s%s" % [hour, minute, second, decimal, offset]
        dt = Time.parse(time_only)
      else
        iso8601 = sprintf("%04d-%02d-%02dT%02d:%02d:%02d%s%s", year, month, day, hour, minute, second, decimal, offset)
        $stderr.puts iso8601
        dt = Time.iso8601(iso8601)
      end
      

      return dt
    end
    
    
    def strptime(input_text, format)
      Time.strptime(input_text, format)
    end
    
    
  end # class Parser
  
end # module Dtconv


# EOF
