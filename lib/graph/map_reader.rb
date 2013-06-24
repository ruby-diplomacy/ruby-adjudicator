require 'yaml'
require 'graph/graph'
require 'parser/state_parser'

module Diplomacy
  class MapReader
    attr_accessor :maps
    
    def initialize(map_path = nil)
      @logger = Diplomacy.logger
      @maps = {}

      map_path ||= File.expand_path('../maps/', File.dirname(__FILE__))

      Dir.chdir map_path do
        Dir.glob "*.yaml" do |mapfile|
          read_map_file(mapfile)
        end
      end
    end
    
    def read_map_file(yaml_file)
      yamlmaps = YAML::load_file(yaml_file)
      
      yamlmaps.keys.each do |mapname|
        yamlmap = yamlmaps[mapname]
        map = Map.new
        yamlmap['Areas'].each do |area|
          map.areas[area[0].to_sym] = Area.new(area[1].to_sym, area[0].to_sym)
        end
        
        yamlmap['Borders'].each do |border|
          border_types = border[2..-1]
          if border_types.member? "L"
            map.add_border(border[0].to_sym, border[1].to_sym, Area::LAND_BORDER)
          end
          if border_types.member? "S"
            map.add_border(border[0].to_sym, border[1].to_sym, Area::SEA_BORDER)
          end
        end

        yamlmap['SCs'].each do |sc|
          map.add_supply_center(sc)
        end
	
      	yamlmap['Powers'].each do |power, starting_state|
          sp = StateParser.new
          gamestate = sp.parse_power_state starting_state[0], power # the first entry contains the power's units

          gamestate.each_value { |area_state| area_state.owner = power } # powers controls all starting units' areas

          starting_state[1..-1].each do |area| # the rest are single areas belonging to their state
            @logger.debug "Adding #{area} for #{power}"
            gamestate[area.to_sym] = AreaState.new power
          end

          map.add_power(power, gamestate)
      	end

        @logger.debug "Parsed map #{mapname}: #{map}"
        
        @maps[mapname] = map
      end
    end
  end
end
