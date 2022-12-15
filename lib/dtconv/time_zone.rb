# coding: utf-8


class Time 
  attr_accessor :offset
end

module Dtconv

  class TimeZone
  
    ZONE_OFFSETS = {
      "PST" => "-08:00",
      "MST" => "-07:00",
      "CST" => "-06:00",
      "EST" => "-05:00",
      "Z" => "+00:00",
      "UTC" => "+00:00",
      "GMT" => "+00:00",
      "CET" => "+01:00",
      "IST" => "+05:30",
      "JST" => "+09:00"
    }

    def self.zone2offset(time_zone)
      return ZONE_OFFSETS[time_zone] || ""
    end
    
  end # class TimeZone
  
end # module Dtconv


# EOF