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
    attr_accessor :owner, :unit, :coast, :embattled

    def initialize(owner=nil, unit=nil, coast=nil, embattled=false)
      @owner = owner
      @unit = unit
      @coast = coast
      @embattled = embattled
    end

    def conquer
      @owner = @unit.nationality unless @unit.nil?
    end

    def to_s
      out = []
      out << "#{@owner}"
      out << "#{@unit.type_to_s}#{@coast.nil? ? "" : " #{@coast}"} (#{@unit.nationality})" if @unit
      out << "(emb.)" if @embattled
      out.join ","
    end

    def ==(other)
      return (@owner == other.owner and @unit == other.unit and @coast == other.coast)
    end
  end

  class GameState < Hash
    attr_accessor :dislodges

    def initialize
      self.default_proc = proc {|this_hash, nonexistent_key| this_hash[nonexistent_key] = AreaState.new }
      @dislodges = {}
    end

    def area_state(area)
      if Area === area
        self[area.abbrv] || (self[area.abbrv] = AreaState.new)
      elsif Symbol === area
        self[area] || (self[area] = AreaState.new)
      end
    end

    def dislodge_state(area)
      if Area === area
        @dislodges[area.abbrv] || DislodgeTuple.new(nil, nil)
      elsif Symbol === area
        @dislodges[area] || DislodgeTuple.new(nil, nil)
      end
    end

    def embattled
      (self.select {|area, area_state| area_state.embattled }).keys
    end

    def area_unit(area)
      area_state(area).unit
    end

    def set_area_unit(area, unit)
      area_state(area).unit = unit
    end

    def dislodge_attacker_origin(dislodge_order)
      dislodge_state(dislodge_order.unit_area).origin_area
    end

    def apply_orders!(orders)
      orders.each do |order|
        if Move === order
          # mark area embattled for all moves - it will only matter in empty areas
          self[order.dst].embattled = true

          if order.succeeded?
            if (unit = area_unit(order.dst))
              @dislodges[order.dst] = DislodgeTuple.new(unit, order.unit_area)
            end

            set_area_unit(order.dst, area_unit(order.unit_area))
            set_area_unit(order.unit_area, nil)
          end
        end
      end
    end

    def apply_retreats!(retreats)
      retreats.each do |r|
        set_area_unit(r.dst, @dislodges[r.unit_area].unit) if r.succeeded?
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

  class DislodgeTuple
    attr_accessor :unit
    attr_accessor :origin_area

    def initialize(unit, origin_area)
      @unit = unit
      @origin_area = origin_area
    end

    def to_s
      "#{@unit.type_to_s}(#{@unit.nationality})*#{@origin_area}"
    end
  end
end
