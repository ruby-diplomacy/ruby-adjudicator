module Diplomacy
  class StateParser
    def initialize(gamestate = nil)
      @gamestate = gamestate || GameState.new
    end

    def parse_state(blob)
      state_by_power = blob.split
      state_by_power.each do |string|
        power, state = string.split(":")
        if power and state
          parse_power_state(state, power)
        end
      end
      @gamestate
    end

    def parse_power_state(blob, power)
      #area_state_array = blob.scan(/[AF]\w{3}/)
      area_state_array = blob.split %r{,\s*}
  
      area_state_array.each do |area_state_blob|
        area, area_state = parse_area_state(area_state_blob, power)
        area_state.owner = power
        @gamestate[area.to_sym] = area_state
      end
      @gamestate
    end

    def parse_area_state(blob, power)
      m = /([AF])?(\w{3})/.match(blob)
      unit = nil
      if m[1]
        unit = Unit.new power, unit_type(m[1])
      end
      return m[2], AreaState.new(nil, unit)
    end

    def unit_type(abbrv)
      return Unit::ARMY if abbrv == "A"
      return Unit::FLEET if abbrv == "F"
    end

    def dump_state
      output = []
      powers = {}
      @gamestate.each do |area, area_state|
        (powers[area_state.unit.nationality] ||= Hash.new )[area] = area_state if not area_state.unit.nil?
      end
      powers.each do |power, area_states|
        output << dump_power(power, area_states)
      end
      output.join " "
    end

    def dump_power(power, area_states)
      return "" if area_states.empty?
      output = "#{power}:"
      dumped_areas = []
      area_states.each do |area, area_state|
        dumped_areas << dump_area_state(area, area_state)
      end
      output << dumped_areas.join(",")
    end

    def dump_area_state(area, area_state)
      "#{area_state.unit.type_to_s}#{area}"
    end
  end
end
