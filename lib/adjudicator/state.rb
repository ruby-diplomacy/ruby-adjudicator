module Diplomacy

  class Unit
    ARMY = 1
    FLEET = 2
    
    attr_accessor :nationality
    attr_accessor :type
    
    def initialize(nationality=nil, type=nil)
      @nationality = nationality
      @type = type
    end

    def is_army?
      type == ARMY
    end

    def is_fleet?
      type == FLEET
    end

    def type_to_s
      return "A" if is_army?
      return "F" if is_fleet?
      return "Unknown"
    end

    def ==(other)
      return ((not other.nil?) and @nationality == other.nationality and @type == other.type)
    end
  end

  class AreaState
    attr_accessor :owner, :unit, :coast

    def initialize(owner=nil, unit=nil, coast=nil)
      @owner = owner
      @unit = unit
      @coast = coast
    end

    def conquer
      @owner = @unit.nationality unless @unit.nil?
    end

    def to_s
      out = []
      out << "#{@owner}"
      out << "#{@unit.type_to_s}#{@coast.nil? ? "" : " #{@coast}"} (#{@unit.nationality})" if @unit
      out.join ","
    end

    def ==(other)
      return (@owner == other.owner and @unit == other.unit and @coast == other.coast)
    end
  end

  class GameState < Hash
    attr_accessor :retreats
    
    def initialize
      self.default_proc = proc {|this_hash, nonexistent_key| this_hash[nonexistent_key] = AreaState.new }
      @retreats = {}
    end
    
    def area_state(area)
      if Area === area
        self[area.abbrv] || (self[area.abbrv] = AreaState.new)
      elsif Symbol === area
        self[area] || (self[area] = AreaState.new)
      end
    end
    
    def area_unit(area)
      area_state(area).unit
    end
    
    def set_area_unit(area, unit)
      area_state(area).unit = unit
    end
    
    def apply_orders!(orders)
      orders.each do |order|
        if Move === order && order.succeeded?
          if (dislodged_unit = area_unit(order.dst))
            @retreats[order.dst] = area_unit(order.dst)
          end
          
          set_area_unit(order.dst, area_unit(order.unit_area))
          set_area_unit(order.unit_area, nil)
        end
      end
    end

    def apply_retreats!(retreats)
      retreats.each do |r|
        set_area_unit(r.dst, @retreats[r.unit_area]) if r.succeeded?
        # do nothing about the failed ones, they will be discarded
      end
    end

    def apply_builds!(builds)
      builds.each do |b|
        set_area_unit(b.unit_area, b.build ? b.unit : nil) if b.succeeded?
      end
    end

    def adjust!(map)
      self.each do |abbrv, area_state|
        area_state.conquer if map.areas[abbrv].is_land?
      end
    end

    def ==(other)
      return false if other.keys() != self.keys()
      self.each do |k, v|
        return false if other[k] != v
      end
      return true
    end
  end
end
