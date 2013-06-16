module Diplomacy
  class StateParser
    def initialize(gamestate = nil)
      @gamestate = gamestate || GameState.new
    end

    def parse_units(unitblob)
      units_by_power = unitblob.split
      units_by_power.each do |string|
        power, units = string.split(":")
        if power and units
          unit_array = units.scan(/[AF]\w{3}/)
      
          unit_array.each do |unit|
            type, area = parse_single_unit(unit)
            @gamestate[area.to_sym] = AreaState.new(nil, Unit.new(power, unit_type(type)))
          end
        end
      end
      @gamestate
    end
  
    def parse_single_unit(unitblob)
      m = /([AF])(\w{3})/.match(unitblob)
      return m[1],m[2]
    end
  
    def unit_type(abbrv)
      return Diplomacy::Unit::ARMY if abbrv == "A"
      return Diplomacy::Unit::FLEET if abbrv == "F"
    end
  end
end
