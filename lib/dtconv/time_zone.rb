# coding: utf-8


module Dtconv

  class TimeZone
  
    ZONE_OFFSETS = {
      "PST" => "-08:00",
      "Z" => "+00:00",
      "UTC" => "+00:00",
      "GMT" => "+00:00",
      "IST" => "+05:30",
      "JST" => "+09:00"
    }

    def self.zone2offset(time_zone)
      return ZONE_OFFSETS[time_zone] || ""
    end
    
  end # class TimeZone
  
end # module Dtconv


# EOF