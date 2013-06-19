module Diplomacy
  class StateParser
    def initialize(gamestate = nil)
      @gamestate = gamestate || GameState.new
    end

    def parse_units_by_power(unitblob)
      units_by_power = unitblob.split
      units_by_power.each do |string|
        power, units = string.split(":")
        if power and units
          parse_units_of_power(units, power)
        end
      end
      @gamestate
    end

    def parse_units_of_power(unitblob, power)
      unit_array = unitblob.scan(/[AF]\w{3}/)
  
      unit_array.each do |unit|
        type, area = parse_single_unit(unit)
        @gamestate[area.to_sym] = AreaState.new(power, Unit.new(power, unit_type(type)))
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
