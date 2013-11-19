module Diplomacy
  class StateParser
    Embattled_prefix = "Embattled:"

    def initialize(gamestate = nil)
      @gamestate = gamestate || GameState.new
    end

    def parse_state(blob)
      @gamestate = GameState.new

      segments = blob.split

      embattled_blob = extract_embattled(segments)

      state_by_power = segments
      state_by_power.each do |string|
        power, state = string.split(":")
        if power and state
          parse_power_state(state, power)
        end
      end

      parse_embattled(embattled_blob)

      @gamestate
    end

    def parse_power_state(blob, power)
      unit_array, area_state_array = blob.split "|"

      unless unit_array.nil? or unit_array.empty?
        unit_array = unit_array.split %r{,\s*}
        unit_array.each do |unit_blob|
          area, area_state, dislodge_origin = parse_unit(unit_blob, power)
          if dislodge_origin
            @gamestate.dislodges[area] = DislodgeTuple.new(area_state.unit, dislodge_origin)
          else
            @gamestate[area] = area_state
          end
        end
      end

      unless area_state_array.nil? or area_state_array.empty?
        area_state_array = area_state_array.split %r{,\s*}
        area_state_array.each do |area_state_blob|
          area, area_state = parse_area_state(area_state_blob, power)

          if @gamestate.has_key? area.to_sym
            @gamestate[area.to_sym].owner = area_state.owner
          else
            @gamestate[area.to_sym] = area_state
          end
        end
      end
      @gamestate
    end

    def dump_state
      output = []
      powers = {}
      @gamestate.each do |area, area_state|
        unless area_state.unit.nil?
          nationality = area_state.unit.nationality

          unless powers.has_key? nationality
            powers[nationality] = StateParser.empty_power_state
          end
          full_area = :"#{area}#{ area_state.coast.nil? ? "" : "(#{area_state.coast})"}"
          powers[nationality][:units][full_area] = area_state.unit
        end
        unless area_state.owner.nil?
          unless powers.has_key? area_state.owner
            powers[area_state.owner] = StateParser.empty_power_state
          end
          powers[area_state.owner][:areas] << area
        end
      end

      @gamestate.dislodges.each do |area, dislodge_tuple|
        nationality = dislodge_tuple.unit.nationality

        unless powers.has_key? nationality
          powers[nationality] = StateParser.empty_power_state
        end

        powers[nationality][:dislodges][area] = dislodge_tuple
      end

      powers.each do |power, state|
        output << dump_power(power, state)
      end

      output << dump_embattled(@gamestate.embattled) unless @gamestate.embattled.nil? or @gamestate.embattled.empty?

      output.join " "
    end

    private

    def parse_unit(blob, power)
      m = /(?'unit_type'[AF])(?'unit_area'\w{3})(\((?'unit_area_coast'.+?)\))?(\*(?'dislodge_origin'\w{3}))?/.match(blob)
      dislodge_origin = m['dislodge_origin'].nil? ? nil : m['dislodge_origin'].to_sym
      return m['unit_area'].to_sym, AreaState.new(nil, Unit.new( power.to_sym, unit_type(m['unit_type'])), m['unit_area_coast']), dislodge_origin
    end

    def parse_area_state(blob, power)
      m = /(\w{3})/.match(blob)
      return m[1], AreaState.new(power.to_sym, nil)
    end

    def unit_type(abbrv)
      return Unit::ARMY if abbrv == "A"
      return Unit::FLEET if abbrv == "F"
    end

    def extract_embattled(segments)
      if segments[-1].start_with? Embattled_prefix
        segments.pop.split(":")[1]
      end
    end

    def parse_embattled(embattled_blob)
      return if embattled_blob.nil? or embattled_blob.empty?

      embattled_blob.split(",").each do |area|
        area = area.to_sym
        if @gamestate.has_key? area
          @gamestate[area].embattled = true
        else
          @gamestate[area] = AreaState.new(nil, nil, nil, true)
        end
      end
    end

    def dump_power(power, state)
      return "" if state.empty? # avoid Power: output

      output = "#{power}:"
      dumped_units = []

      state[:units].each do |area, unit|
        dumped_units << dump_unit(area, unit)
      end

      state[:dislodges].each do |area, dislodge_tuple|
        dumped_units << dump_dislodge(area, dislodge_tuple)
      end

      output << dumped_units.join(",")

      output << "|" unless state[:areas].empty?

      output << state[:areas].join(",")
    end

    def dump_unit(area, unit)
      "#{unit.type_to_s}#{area}"
    end

    def dump_dislodge(area, dislodge_tuple)
      "#{dump_unit(area, dislodge_tuple.unit)}*#{dislodge_tuple.origin_area}"
    end

    def dump_embattled(embattled)
      Embattled_prefix + embattled.join(",")
    end

    def self.empty_power_state
      { units: {}, areas: [], dislodges: {} }
    end
  end
end
